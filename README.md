# ansi256

ansi256 is a rubygem for colorizing text with ANSI escape codes.

Features:

- True 24-bit color, named colors, and 256-color support
- Underline styles (curly, double, dotted, dashed) and underline colors
- Allows nesting of colored text
- Generates optimal(shortest) code sequence

## Installation

    $ gem install ansi256

Basic usage
-----------

### Numeric 256-color codes

```ruby
require 'ansi256'

# Foreground color
puts "Colorize me".fg(111)

# With background color
puts "Colorize me".fg(111).bg(226)

# Also with underline
puts "Colorize me".fg(111).bg(226).underline

# Underline styles (single, double, curly, dotted, dashed)
puts "Colorize me".underline(:curly)

# Underline with color (256-color index or hex RGB)
puts "Colorize me".underline(:curly, 'ff9900')
puts "Colorize me".underline(214)

# Strip ANSI codes
puts "Colorize me".fg(111).bg(226).underline.plain
```

![colorize-me](https://github.com/junegunn/ansi256/raw/master/colorize-me.png)

### 16 named colors

```ruby
s = "Colorize me"
puts [ s.black,   s.black.bold,   s.white.bold.on_black   ].join ' '
puts [ s.red,     s.red.bold,     s.white.bold.on_red     ].join ' '
puts [ s.green,   s.green.bold,   s.white.bold.on_green   ].join ' '
puts [ s.yellow,  s.yellow.bold,  s.white.bold.on_yellow  ].join ' '
puts [ s.blue,    s.blue.bold,    s.white.bold.on_blue    ].join ' '
puts [ s.magenta, s.magenta.bold, s.white.bold.on_magenta ].join ' '
puts [ s.cyan,    s.cyan.bold,    s.white.bold.on_cyan    ].join ' '
puts [ s.white,   s.white.bold,   s.white.bold.on_white   ].join ' '
```

![colorize-me-16](https://github.com/junegunn/ansi256/raw/master/colorize-me-16.png)

### RGB hex colors

RGB hex strings produce true 24-bit color (`\e[38;2;R;G;Bm`) by default.

```ruby
puts "RGB Color (RRGGBB)".fg('ff9930').bg('203366')

puts "RGB Color (R-G-B-)".fg('f90').bg('036')

puts "RGB Color (Monochrome)".fg('ef').bg('3f')
```

To approximate RGB to 256-color indices instead (for legacy terminals):

```ruby
Ansi256.truecolor = false
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

Ansi256 methods
---------------

```ruby
Ansi256.fg(232)
Ansi256.bg(226)
Ansi256.green
Ansi256.on_green
Ansi256.bold
Ansi256.dim
Ansi256.italic
Ansi256.underline
Ansi256.reset

Ansi256.fg(232, 'Hello')
Ansi256.bg(226, 'World')
Ansi256.green('Hello World')
```

Disabling extended String methods
---------------------------------

```ruby
Ansi256.enabled?
  # true

# Print colored output only when STDOUT is tty
Ansi256.enabled = $stdout.tty?

"Hello".fg(232)
  # Hello
```

Color chart
-----------

### 256-color table

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

### Reference chart

![xterm-color-chart.png](https://github.com/junegunn/ansi256/raw/master/xterm-color-chart.png)

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
