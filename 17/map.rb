class Map
  def self.from_clay_veins(io, xstart:, ystart:)
    map = Hash.new ?.
    map[[xstart, ystart]] = ?+

    while line = io.gets
      xs, ys = line.scan(/(\w+)=(\d+(?:..\d+)?)/).map { |coord, values|
        values = values.scan(/\d+/).map(&:to_i)
        values << values.first if values.size == 1
        first, last = values
        first.upto(last).map { |value|
          [coord, value]
        }
      }.sort
      xs.map! &:last
      ys.map! &:last
      xs << xs.last while xs.size < ys.size
      ys << ys.last while ys.size < xs.size
      xs.zip(ys).each { |x, y| map[[x, y]] = '#' }
    end

    ymin, ymax = map.keys.map(&:last).minmax
    xmin, xmax = map.keys.map(&:first).minmax
    xmin -= 1
    xmax += 1

    new map: map, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax, xstart: xstart, ystart: ystart
  end


  attr_reader :map, :xmin, :xmax, :ymin, :ymax, :xstart, :ystart

  def initialize(map:, xmin:, xmax:, ymin:, ymax:, xstart:, ystart:)
    @map, @xmin, @xmax, @ymin, @ymax, @xstart, @ystart =
      map, xmin, xmax, ymin, ymax, xstart, ystart
  end

  def sum
    (ymin..ymax).sum do |y|
      (xmin..xmax).count do |x|
        map[[x, y]] == ?~ || map[[x, y]] == ?|
      end
    end
  end

  def big?
    xmax - xmin >= 20 || ymax - ymin >= 20
  end

  def to_s
    (ymin..ymax).map { |y|
      (xmin..xmax).map { |x| map[[x, y]] }.join
    }.join("\n")
  end

  def fill
    faucet xstart, ystart, :up
  end

  def faucet(x, y, from)
    return true if x > xmax || y > ymax || x < xmin || y < ymin

    case map[[x, y]]
    when ?#
      false
    when ?+
      faucet x, y+1, :up
    when ?.
      map[[x, y]] = ?|
      case from
      when :up
        if faucet(x, y+1, :up)
          true
        elsif faucet(x-1, y, :right) | faucet(x+1, y, :left)
          true
        else
          map[[x, y]] = ?~
          false
        end
      when :right
        if faucet(x, y+1, :up)
          true
        elsif faucet(x-1, y, :right)
          true
        else
          map[[x, y]] = ?~
          false
        end
      when :left
        if faucet(x, y+1, :up)
          true
        elsif faucet(x+1, y, :left)
          true
        else
          map[[x, y]] = ?~
          false
        end
      end
    end
  end

end
