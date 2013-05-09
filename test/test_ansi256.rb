$VERBOSE = true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ansi256'

def cfmt col
  col.to_s.rjust(5).fg(232).bg(col)
end

puts (0..7).map  { |col| cfmt col }.join
puts (8..15).map { |col| cfmt col }.join
(16..255).each_slice(6) do |slice|
  puts slice.map { |col| cfmt col }.join
end

# Wrap

a = ' '
(16..60).each do |i|
  a = "<#{a}>".bg(i).fg(i * 2).underline
end
puts a

# Nesting
puts world = "World".bg(226).fg(232).underline
puts hello = "Hello #{world} !".fg(230).bg(75)
puts say_hello_world = "Say '#{hello}'".fg(30)
puts say_hello_world.plain.fg(27)

