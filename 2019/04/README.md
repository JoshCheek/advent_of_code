https://adventofcode.com/2019/day/4

```bash
$ ruby -e '
def increment(digits, i=digits.size-1)
  if digits[i] < 9
    digits[i] += 1
  else
    digits[i] = increment(digits, i-1)
  end
end

def continue?(start, stop)
  start.zip(stop).each do |a, b|
    return true if a < b
    next if a == b
    return false
  end
end

def each(start, stop)
  start = start.chars.map(&:to_i)
  stop  = stop.chars.map(&:to_i)
  start.each_index.drop(1).each do |i|
    next if start[i] >= start[i-1]
    (i...start.size).each { |i| start[i] = start[i-1] }
  end
  while continue? start, stop
    yield start
    increment start
  end
end

puzzle1 = puzzle2 = 0
each "124075", "580769" do |digits|
  lengths = digits.slice_when { |a, b| a != b }.map(&:size)
  next if lengths.max == 1
  puzzle1 += 1
  puzzle2 += 1 if lengths.include? 2
end

p puzzle1, puzzle2'
```
