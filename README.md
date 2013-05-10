# Ansi256

Decorate text with 256-color ANSI codes.

## Installation

    $ gem install ansi256

Basic usage
-----------

```ruby
require 'ansi256'

# Foreground color
puts "Colorize me".fg(111)

# With background color
puts "Colorize me".fg(111).bg(226)

# Also with underline
puts "Colorize me".fg(111).bg(226).underline

# Strip ANSI codes
puts "Colorize me".fg(111).bg(226).underline.plain
```

![colorize-me](https://github.com/junegunn/ansi256/raw/master/colorize-me.png)

Added methods (`fg`, `bg`, `underline`, and `plain`)
return new String object and do not modify the original String.

256-color table
---------------

```ruby
require 'ansi256'

def cfmt col
  col.to_s.rjust(5).fg(232).bg(col)
end

puts (0..7).map  { |col| cfmt col }.join
puts (8..15).map { |col| cfmt col }.join
(16..255).each_slice(6) do |slice|
  puts slice.map { |col| cfmt col }.join
end
```

Nesting
-------

Unlike the other similar gems, Ansi256 allows you to nest colored text.

```ruby
require 'ansi256'

puts           world = "World".bg(226).fg(232).underline
puts     hello_world = "Hello #{world} !".fg(230).bg(75)
puts say_hello_world = "Say '#{hello_world}'".fg(30)
puts say_hello_world.plain.fg(27)
```

![say-hello-world](https://github.com/junegunn/ansi256/raw/master/say-hello-world.png)

_"Just gimme the code"_
-----------------------

```ruby
Ansi256.fg(232)
Ansi256.bg(226)
Ansi256.underline
Ansi256.reset
```


ansi256 executable
------------------

Ansi256 comes with ansi256 script which can be used as follows

```bash
> ansi256
usage: ansi256 [-u] <[fg][/bg]> [mesage]

> ansi256 232/226 "Hello world"

> ls | ansi256 -u /226

> ansi256 30 "Say '$(ansi256 230/75 "Hello $(ansi256 -u 232/226 World)")'"
```

Color chart
-----------

![xterm-color-chart.png](https://github.com/junegunn/ansi256/raw/master/xterm-color-chart.png)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
