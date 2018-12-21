def react?(unit1, unit2)
  unit1 != unit2 && unit1.upcase == unit2.upcase
end

def collapse(polymer)
  before, after = [], polymer.chars
  loop do
    break                     unless first  = before.pop || after.shift
    break before.push first   unless second = after.shift
    before.push first, second unless react? first, second
  end
  before.size
end

polymer = $stdin.read.chomp # fkn newline cost me like an hour -.-

# 5.1
p collapse polymer

# 5.2
p polymer.downcase.chars.uniq.map { |c| collapse polymer.delete c+c.upcase }.min
# p collapse polymer
