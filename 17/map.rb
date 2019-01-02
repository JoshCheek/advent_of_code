class Map
  SAND    = " "
  SETTLED = "~"
  FLOWING = "|"
  CLAY    = "#"
  WELL    = "+"

  def self.from_clay_veins(io, xstart:, ystart:)
    map = Hash.new SAND
    map[[xstart, ystart]] = WELL

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
      xs.zip(ys).each { |x, y| map[[x, y]] = CLAY }
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
        map[[x, y]] == SETTLED || map[[x, y]] == FLOWING
      end
    end
  end

  def big?
    width >= 40 || height >= 40
  end

  def width
    xmax - xmin
  end

  def height
    ymax - ymin
  end

  def to_s
    show x: xmin, y: ymin, width: width, height: height
  end

  def show(x:, y:, width:, height:)
    (y..y+height-1).map { |crnt_y|
      (x..x+width-1).map { |crnt_x| map[[crnt_x, crnt_y]] }.join
    }.join("\n")
  end

  def fill
    faucet xstart, ystart, :up
  end

  def faucet(x, y, from)
    return true if x > xmax || y > ymax || x < xmin || y < ymin

    case map[[x, y]]
    when CLAY
      false
    when SAND, WELL
      map[[x, y]] = FLOWING unless map[[x, y]] == WELL
      case from
      when :up
        if faucet(x, y+1, :up)
          true
        elsif faucet(x-1, y, :right) | faucet(x+1, y, :left)
          true
        else
          map[[x, y]] = SETTLED unless map[[x, y]] == WELL
          false
        end
      when :right
        if faucet(x, y+1, :up)
          true
        elsif faucet(x-1, y, :right)
          true
        else
          map[[x, y]] = SETTLED unless map[[x, y]] == WELL
          false
        end
      when :left
        if faucet(x, y+1, :up)
          true
        elsif faucet(x+1, y, :left)
          true
        else
          map[[x, y]] = SETTLED unless map[[x, y]] == WELL
          false
        end
      end
    end
  end

end
