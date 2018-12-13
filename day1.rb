# https://adventofcode.com/2018/day/1

def get_input
  input = []
  File.open("input/day1.txt").each do |line|
    input << line.to_i
  end

  return input
end

# 1.1: Add all inputs (frequency shifts).
def part1(input)
  input.reduce(:+)
end

# 1.2 Cycle through frequencies to find the first repeat.
def part2(input)
  current_freq = 0
  seen_frequencies = {0 => true}

  while true
    input.each do |shift|
      current_freq += shift
      if seen_frequencies[current_freq]
        # If we've seen this before, we're done.
        return current_freq
      end

      seen_frequencies[current_freq] = true
    end
  end
end

input = get_input
puts part1(input)
puts part2(input)
