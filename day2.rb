# https://adventofcode.com/2018/day/2

def get_input
  input = []
  File.open("input/day2.txt").each do |line|
    input << line.strip
  end

  return input
end

# 2.1: Determine the "checksum" of a list of IDs by counting
# the number of IDs that have exactly 2 of any letter and multiply
# by the number of IDs that have exactly 3 of any letter.
def part1(input)
  twos = threes = 0

  # For each ID, bucket each char and count their instances within the ID.
  # Originally, I'd tried to sort the chars and use a regex, but getting
  # around the awkwardness of backtracking and detecting the twos that aren't
  # also threes (or more) wasn't worth the effort on this exercise.
  input.each do |id|
    counts = id.chars.group_by(&:to_s).values.map(&:size)

    twos += 1 if counts.include?(2)
    threes += 1 if counts.include? (3)
  end

  return twos * threes
end

# Given 2 arrays, detect if they differ by exactly one item when
# compared position-to-position. If so, return the remainder of the array.
def has_one_diff(a, b)
  # Track whether we've already seen one diff.
  has_diff = false
  matched = []

  a.each_with_index do |i, idx|
    if b[idx] == i
      matched << i
    else
      # It's a diff. If we've already seen one, fail the test.
      if has_diff
        return nil
      else
        has_diff = true
      end
    end
  end

  # Return the matching elements of the array only if there was at
  # least one diff. (More than that would have already exited.)
  return matched if has_diff
end

# 2.2: Given a set of IDs, there are two that differ by only one character.
# Find those IDs and return the string of characters that did not differ.
def part2(input)
  # Compare every ID to every other ID until we fulfill our search.
  # Because the diff can be anywhere in the string, there's not an
  # obvious optimization to eliminate pairs early.
  (0..(input.length-2)).each do |i|
    ((i+1)..(input.length-1)).each do |j|
      a = input[i]
      b = input[j]

      # Compare the arrays, and get back either nil or the matching chars.
      r = has_one_diff(a.chars, b.chars)
      return r.join if r
    end
  end
end

input = get_input
puts part1(input)
puts part2(input)
