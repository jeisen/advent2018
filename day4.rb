# https://adventofcode.com/2018/day/4

require 'time'

def get_input
  input = []
  File.open("input/day4.txt").each do |line|
    input << line.strip
  end

  return input.sort
end

def sample_input
  input = []
  input << "[1518-11-01 00:00] Guard #10 begins shift"
  input << "[1518-11-01 00:05] falls asleep"
  input << "[1518-11-01 00:25] wakes up"
  input << "[1518-11-01 00:30] falls asleep"
  input << "[1518-11-01 00:55] wakes up"
  input << "[1518-11-01 23:58] Guard #99 begins shift"
  input << "[1518-11-02 00:40] falls asleep"
  input << "[1518-11-02 00:50] wakes up"
  input << "[1518-11-03 00:05] Guard #10 begins shift"
  input << "[1518-11-03 00:24] falls asleep"
  input << "[1518-11-03 00:29] wakes up"
  input << "[1518-11-04 00:02] Guard #99 begins shift"
  input << "[1518-11-04 00:36] falls asleep"
  input << "[1518-11-04 00:46] wakes up"
  input << "[1518-11-05 00:03] Guard #99 begins shift"
  input << "[1518-11-05 00:45] falls asleep"
  input << "[1518-11-05 00:55] wakes up"

  return input.sort
end

# Simple structure for tracking a guard's shift.
class GuardShift
  def initialize(ts)
    @shift_start = ts
    @sleep_log = []
  end

  def end_shift(ts)
    @end_shift = ts
  end

  def sleep(ts)
    @current_sleep = ts
  end

  def wake(ts)
    # We only care about sleep during the midnight hour.
    start_min = 0
    start_min = @current_sleep.min if @current_sleep.hour == 0
    end_min = 0
    end_min = ts.min if ts.hour == 0

    @sleep_log << [start_min, end_min] if (start_min + end_min != 0)
    @current_sleep = nil
  end

  def sleeping?
    !@current_sleep.nil?
  end

  def time_slept
    @sleep_log.inject(0) { |sum, nap| sum + (nap[1] - nap[0]) }
  end

  def minutes_slept
    @sleep_log.inject([]) { |list, nap| list += (nap[0]...nap[1]).to_a }.flatten
  end
end

# Structure to track a guard across multiple shifts.
class Guard
  attr_reader :id

  def initialize(id)
    @id = id
    @shifts = []
  end

  def start_shift(ts)
    raise "ERROR: GUARD #{@id} ALREADY WORKING!" if @current_shift
    @current_shift = GuardShift.new(ts)
  end

  def end_shift(ts)
    raise "ERROR: GUARD #{@id} NOT WORKING" unless @current_shift
    @current_shift.end_shift(ts)
    @shifts << @current_shift
    @current_shift = nil
  end

  def sleep(ts)
    raise "ERROR: GUARD #{@id} NOT WORKING" unless @current_shift
    raise "ERROR: GUARD #{@id} ALREADY SLEEPING!" if @current_shift.sleeping?
    @current_shift.sleep(ts)
  end

  def wake(ts)
    raise "ERROR: GUARD #{@id} NOT WORKING" unless @current_shift
    raise "ERROR: GUARD #{@id} NOT SLEEPING!" unless @current_shift.sleeping?
    @current_shift.wake(ts)
  end

  def time_slept
    @shifts.inject(0) { |sum, shift| sum + shift.time_slept }
  end

  # Table of how often a guard is sleeping at a particular minute.
  def sleep_frequencies
    minutes = Hash.new(0)
    @shifts.each do |shift|
      shift.minutes_slept.each do |min|
        minutes[min] += 1
      end
    end
    minutes
  end
end

# Structure to track all guards and all shifts by parsing the input.
class GuardLog
  def initialize(input)
    @guard_map = {}
    input.each do |log_line|
      parse_log(log_line)
    end
    @current_guard.end_shift(nil) if @current_guard
  end

  # Log example:
  # [1518-11-17 23:53] Guard #853 begins shift
  def self.log_matcher
    @log_matcher ||= Regexp.new('\[(\d+\-\d+\-\d+ \d+\:\d+)\] (.+)')
  end

  # Shift start example:
  # Guard #853 begins shift
  def self.shift_start_matcher
    @shift_start_matcher ||= Regexp.new('Guard \#(\d+) begins shift')
  end

  # Parse the appropriate action from the log, initialize a Guard
  # if necessary, and log the action's timestamp.
  def parse_log(log_line)
    m = self.class.log_matcher.match(log_line)
    ts, action = Time.parse(m[1]), m[2] if m

    if @current_guard && action == "falls asleep"
      @current_guard.sleep(ts)
    elsif @current_guard && action == "wakes up"
      @current_guard.wake(ts)
    else
      m = self.class.shift_start_matcher.match(action)
      raise "Unknown action #{action}" unless m

      @current_guard.end_shift(ts) if @current_guard

      guard_id = m[1].to_i
      @current_guard = (@guard_map[guard_id] ||= Guard.new(guard_id))
      @current_guard.start_shift(ts)
    end
  end

  def guards
    @guard_map.values
  end
end

# 4.1: Determine the guard that sleeps the most and the minute most likely
# to be asleep. (Answer multiplies them together.)
def part1(guard_log)
  guard = guard_log.guards.sort_by { |g| g.time_slept }.last
  sleep_frequencies = guard.sleep_frequencies

  # key (minute[0]) is minute in hour, value (minute[1]) is number
  # of times the guard slept at that minute.
  min = sleep_frequencies.sort_by { |minute| minute[1] }.last[0]

  return guard.id * min
end

# 4.2: Determine the guard that is most consistently asleep on the same
# minute, multiplied by that minute.
def part2(guard_log)
  guard_consistencies = guard_log.guards.map do |g|
    sleep_frequencies = g.sleep_frequencies

    # [guard, minute in hour, times sleeping that minute]
    consistent_min = (sleep_frequencies.sort_by { |minute| minute[1] }.last) || [-1, -1]
    [g, consistent_min[0], consistent_min[1]]
  end

  guard, min, times = guard_consistencies.sort_by { |c| c[2] }.last

  return guard.id * min
end

input = get_input
guard_log = GuardLog.new(input)
puts part1(guard_log)
puts part2(guard_log)
