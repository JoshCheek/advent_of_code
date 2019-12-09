class Intcode
  def self.call(**args)
    new(**args).call
  end

  attr_accessor :memory, :ip, :bp, :instream, :outstream

  def initialize(memory:, instream:, outstream:)
    self.memory    = memory.each_with_index.with_object(Hash.new 0) { |(e, i), h| h[i] = e }
    self.instream  = instream
    self.outstream = outstream
    self.ip        = 0 # instruction pointer
    self.bp        = 0 # base pointer
  end

  def get(param)
    n = memory[ip+param]
    case mode_at param
    when :position  then memory[n]
    when :immediate then n
    when :relative  then memory[bp+n]
    end
  end

  def set(param, value)
    n = memory[ip+param]
    n += bp if :relative == mode_at(param)
    memory[n] = value
  end

  def call
    loop do
      case opcode

      when :add
        set 3, get(1) + get(2)
        self.ip += 4

      when :multiply
        set 3, get(1) * get(2)
        self.ip += 4

      when :input
        outstream.print '> ' if outstream.tty?
        set 1, instream.gets.to_i
        self.ip += 2

      when :output
        outstream.puts get(1)
        self.ip += 2

      when :jump_if_true
        if get(1).zero?
          self.ip += 3
        else
          self.ip = get 2
        end

      when :jump_if_false
        if get(1).zero?
          self.ip = get 2
        else
          self.ip += 3
        end

      when :less_than
        set 3, get(1) < get(2) ? 1 : 0
        self.ip += 4

      when :equal_to
        set 3, get(1) == get(2) ? 1 : 0
        self.ip += 4

      when :relative_base_offset
        self.bp += get(1)
        self.ip += 2

      when :halt
        return memory[0]

      else
        return nil
      end
    end
  end

  private

  def instruction
    memory[ip]
  end

  def opcode
    case instruction % 100
    when 1  then :add
    when 2  then :multiply
    when 3  then :input
    when 4  then :output
    when 5  then :jump_if_true
    when 6  then :jump_if_false
    when 7  then :less_than
    when 8  then :equal_to
    when 9  then :relative_base_offset
    when 99 then :halt
    end
  end

  def mode_at(param)
    case (instruction / 100).digits[param-1]
    when 0, nil then :position
    when 1      then :immediate
    when 2      then :relative
    else raise "wut? #{param.inspect}"
    end
  end
end
