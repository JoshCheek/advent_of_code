$stdin = File.open File.expand_path('input', __dir__)

counts = $stdin
  .each_line
  .map { |line|
    timestamp, log = line.split ']'
    year, month, day, hour, minute = timestamp.scan(/\d+/).map(&:to_i)
    data = case log
    when /\d+/        then $&.to_i
    when /sleep|wake/ then $&.intern
    else raise "wat? #{msg.inspect}"
    end
    [Time.new(year, month, day, hour, minute), data]
  }
  .sort
  .slice_before { |time, data| data.is_a? Integer }
  .map { |(_, guard), *events|
    [ guard,
      events.map(&:first).each_slice(2).flat_map { |pre, post| (pre.min...post.min).to_a }
    ]
  }
  .group_by(&:first)
  .transform_values { |shifts|
    shifts.flat_map(&:last).group_by(&:itself).transform_values(&:size)
  }

# strategy 1
guard, minute_counts = counts.max_by { |_, counts| counts.values.sum }
guard * minute_counts.max_by(&:last).first # => 8421

# strategy 2
guard, minute_counts = counts.max_by { |_, counts| counts.values.max||0 }
guard * minute_counts.max_by(&:last).first # => 83359
