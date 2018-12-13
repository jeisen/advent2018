# https://adventofcode.com/2018/day/3

def get_input
  input = []
  File.open("input/day3.txt").each do |line|
    input << line.strip
  end

  return input
end

# Structure to parse and contain the input data as fabric claims.
class FabricClaim
  attr_reader :id, :x, :y, :size_x, :size_y
  attr_accessor :overlapping

  # Claim example:
  # #1 @ 596,731: 11x27
  def self.matcher
    @matcher ||= Regexp.new('\#(\d+) \@ (\d+)\,(\d+)\: (\d+)x(\d+)')
  end

  # Parse claim format into component parts.
  def initialize(input_string)
    m = self.class.matcher.match(input_string)
    @id, @x, @y, @size_x, @size_y = m[1].to_i, m[2].to_i, m[3].to_i, m[4].to_i, m[5].to_i if m
  end

  # Get the list of coords this claim covers as [x,y] pairs.
  def coords
    coord_list = []
    (@x..(@x + @size_x - 1)).each do |i|
      (@y..(@y + @size_y - 1)).each do |j|
        coord = [i, j]
        coord_list << coord
      end
    end

    return coord_list
  end
end

# Structure representing the grid of fabric that claims are made on.
class FabricGrid
  def initialize(claims)
    # We don't know the size of the grid at first, and at this scale
    # it's easier just to treat every point as an independent block in
    # a hashmap.
    @grid = {}
    @claims = []
    claims.each { |claim| add(claim) }
  end

  # Add a claim to the grid by marking all of its coordinates with
  # the claim reference. Multiple claims may be on a coord. when
  # adding a claim to a coord, if other claims are found for the same
  # coord, make them and the new claim as overlapping.
  def add(claim)
    # Track all the claims we see.
    @claims << claim

    claim.coords.each do |coord|
      coord_claims = @grid[coord]
      if coord_claims.nil?
        @grid[coord] = []
      else
        claim.overlapping = true
        coord_claims.each { |other_claim| other_claim.overlapping = true }
      end

      @grid[coord] << claim
    end
  end

  # Find the coords that are claimed multiple times.
  def conflicts
    @grid.values.select { |claims| claims.size > 1 }
  end

  # Find the first claim that has no conflicts.
  def non_overlapping
    @claims.detect { |claim| !claim.overlapping }
  end
end

# Parse input into the component parts.
def parse_claims(input)
  input.map { |claim_string| FabricClaim.new(claim_string) }
end

# 3.1: Given overlapping claims to a grid, find the number of
# coordinates (square inches of fabric) that contain more than one
# claim.
def part1(grid)
  grid.conflicts.size
end

# 3.2: Find the claim that doesn't overlap with any other claims.
def part2(grid)
  grid.non_overlapping.id
end

claims = parse_claims(get_input)
grid = FabricGrid.new(claims)
puts part1(grid)
puts part2(grid)
