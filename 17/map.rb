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
    xmax - xmin + 1
  end

  def height
    ymax - ymin + 1
  end

  def to_s
    show x: xmin, y: ymin, width: width, height: height
  end

  def show(x:, y:, width:, height:)
    (y..y+height-1).map { |crnt_y|
      (x..x+width-1).map { |crnt_x| map[[crnt_x, crnt_y]] }.join
    }.join("\n")
  end

  def fill(&block)
    Enumerator.new do |y|
      faucet(xstart, ystart, :up) { y << nil }
    end.each(&block||->{})
  end

  def faucet(x, y, from, &block)
    return true if x > xmax || y > ymax || x < xmin || y < ymin
    block&.call
    is_well = map[[x, y]] == WELL

    case map[[x, y]]
    when CLAY
      false
    when FLOWING
      true
    when SAND, WELL
      map[[x, y]] = FLOWING
      case from
      when :up
        if faucet(x, y+1, :up, &block)
          true
        elsif faucet(x-1, y, :right, &block) | faucet(x+1, y, :left, &block)
          true
        else
          map[[x, y]] = SETTLED
          false
        end
      when :right
        if faucet(x, y+1, :up, &block)
          true
        elsif faucet(x-1, y, :right, &block)
          true
        else
          map[[x, y]] = SETTLED
          false
        end
      when :left
        if faucet(x, y+1, :up, &block)
          true
        elsif faucet(x+1, y, :left, &block)
          true
        else
          map[[x, y]] = SETTLED
          false
        end
      end
    end
  ensure
    map[[x, y]] = WELL if is_well
  end

end
