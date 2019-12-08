https://adventofcode.com/2019/day/8

```sh
# part 1
$ ruby -e 'p File.read("input.txt").chomp.chars.map(&:to_i).each_slice(25*6).min_by { |digits| digits.count &:zero? }.group_by(&:itself).transform_values(&:size).values_at(1, 2).reduce(:*)'

# part 2
$ ruby -e '
puts File
  .read("input.txt")
  .chomp
  .chars
  .map(&:to_i)
  .each_slice(25*6)
  .to_a
  .transpose
  .map { |layer|
    layer.find { |d| d != 2 }
  }
  .each_slice(25)
  .map(&:join)
  .join("\n")
  .gsub("0", "\e[48m \e[0m")
  .gsub("1", "\e[47m \e[0m")
'
```
