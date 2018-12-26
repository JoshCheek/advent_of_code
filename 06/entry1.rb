require 'set'
require 'io/wait'

# $stdin = DATA
initial_points = $stdin.read.scan(/\d+/).map(&:to_i).each_slice(2).to_a
$stdin.reopen "/dev/tty"

max_x, max_y = initial_points.transpose.map &:max

grid = Array.new(max_y.succ) { Array.new(max_x.succ) {
  { discovered: false, distance: nil, sources: Set.new }
}}

# Just b/c it's easier to mentally keep track of what's what, when they're letters
POINT_NAMES = Enumerator.new do |y|
  name = "A"
  loop do
    y << name
    name = name.succ
  end
end

initial_points.each do |x, y|
  coord = grid[y][x]
  coord[:discovered] = true
  coord[:distance]   = 0
  coord[:sources] << POINT_NAMES.next
end

def each_adjacent(x, y, max_x, max_y)
  yield x,   y-1 unless y.zero?
  yield x-1, y   unless x.zero?
  yield x+1, y   unless x == max_x
  yield x,   y+1 unless y == max_y
end

distance    = -1
next_points = initial_points

until next_points.empty?
  distance   += 1
  points      = next_points
  next_points = Set.new

  p max_x: max_x, max_y: max_y, distance: distance, queue_size: points.size

  points.each do |x, y|
    coordinate = grid[y][x]
    raise "coordinate should already be discovered! x=#{x},y=#{y}" unless coordinate[:discovered]
    raise "distances should match!" unless distance == coordinate[:distance]

    each_adjacent(x, y, max_x, max_y) do |adjacent_x, adjacent_y|
      adjacent_coord = grid[adjacent_y][adjacent_x]
      next if adjacent_coord.fetch(:discovered) && adjacent_coord.fetch(:distance) < distance+1
      adjacent_coord[:discovered] = true
      adjacent_coord[:distance]   = distance+1
      coordinate.fetch(:sources).each { |source| adjacent_coord[:sources] << source }
      next_points << [adjacent_x, adjacent_y]
    end
  end
end

grid.each_with_index do |row, y|
  row.each_with_index do |coord, x|
    raise "Bad coord! #{coord.inspect}" if !coord[:discovered]
    raise "Bad coord! #{coord.inspect}" if !coord[:distance]
    raise "Bad coord! #{coord.inspect}" if coord[:distance] < 0
    raise "Bad coord! #{coord.inspect}" if coord[:distance] > [max_x, max_y].max
    raise "Bad coord! #{coord.inspect}" if coord[:sources].empty?
  end
end

grid.map do |row|
  row.map do |distance:, sources:, **|
    begin
      source = (sources.size == 1 ? sources.first : '.')
      distance.zero? ? source.upcase : source.downcase
    rescue
      require "pry"
      binding().pry
    end
  end.join('')
end
# => ["aaaaa.ccc",
#     "aAaaa.ccc",
#     "aaaddeccc",
#     "aadddeccC",
#     "..dDdeecc",
#     "bb.deEeec",
#     "bBb.eeee.",
#     "bbb.eeeff",
#     "bbb.eefff",
#     "bbb.ffffF"]

counts = grid.each_with_object(Hash.new 0) do |row, counts|
  row.each do |sources:, **|
    counts[sources.first] += 1 unless sources.size > 1
  end
end

borders = [*grid.first, *grid.last, *grid.map(&:first), *grid.map(&:last)]
            .map { |coord| coord[:sources] }
            .uniq
            .select(&:one?)
            .map(&:first)
borders  # => ["A", "C", "B", "F"]
counts   # => {"A"=>15, "C"=>15, "D"=>9, "E"=>17, "B"=>14, "F"=>10}
borders.each { |border| counts.delete border }
counts   # => {"D"=>9, "E"=>17}
p counts.max_by { |source, count| count } # => ["E", 17]

# >> {:max_x=>8, :max_y=>9, :distance=>0, :queue_size=>6}
# >> {:max_x=>8, :max_y=>9, :distance=>1, :queue_size=>21}
# >> {:max_x=>8, :max_y=>9, :distance=>2, :queue_size=>30}
# >> {:max_x=>8, :max_y=>9, :distance=>3, :queue_size=>21}
# >> {:max_x=>8, :max_y=>9, :distance=>4, :queue_size=>9}
# >> {:max_x=>8, :max_y=>9, :distance=>5, :queue_size=>3}
# >> "E"

__END__
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
