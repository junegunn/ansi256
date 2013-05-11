$VERBOSE = true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ansi256'
require 'minitest/autorun'

class TestAnsi256 < MiniTest::Unit::TestCase
  def cfmt col
    col.to_s.rjust(5).fg(232).bg(col)
  end

  # TODO: assertions :p

  def test_256_color_table
    puts (0..7).map  { |col| cfmt col }.join
    puts (8..15).map { |col| cfmt col }.join
    (16..255).each_slice(6) do |slice|
      puts slice.map { |col| cfmt col }.join
    end
  end

  def test_nesting
    a = ' '
    (16..60).each do |i|
      a = "<#{a}>".bg(i).fg(i * 2).underline
    end
    puts a
  end

  def test_nesting_hello_world
    # Nesting
    puts world = "World".bg(226).fg(232).underline
    puts hello = "Hello #{world} !".fg(230).bg(75)
    puts say_hello_world = "Say '#{hello}'".fg(30)
    puts say_hello_world.plain.fg(27)
  end

  def test_nesting_hello_world2
    puts world = "World".bg(226).blue.underline
    puts hello = "Hello #{world} Hello".white.bold
    puts say_hello_world = "Say '#{hello}'".fg(30).underline
    puts say_hello_world.plain.fg(27)
  end

  def test_nesting_hello_world3
    puts world = "World".blue.underline
    puts hello = "Hello #{world} Hello".blue.bold
    puts say_hello_world = "Say '#{hello}'".fg(30).underline
    puts say_hello_world.plain.fg(27)
  end

  def test_named_colors
    s = "Colorize me"
    puts [ s.black,   s.black.bold,   s.white.bold.on_black   ].join ' '
    puts [ s.red,     s.red.bold,     s.white.bold.on_red     ].join ' '
    puts [ s.green,   s.green.bold,   s.white.bold.on_green   ].join ' '
    puts [ s.yellow,  s.yellow.bold,  s.white.bold.on_yellow  ].join ' '
    puts [ s.blue,    s.blue.bold,    s.white.bold.on_blue    ].join ' '
    puts [ s.magenta, s.magenta.bold, s.white.bold.on_magenta ].join ' '
    puts [ s.cyan,    s.cyan.bold,    s.white.bold.on_cyan    ].join ' '
    puts [ s.white,   s.white.bold,   s.white.bold.on_white   ].join ' '
  end

  def test_named_color_code_with_fg_bg
    puts "Colorize me".fg(:green).bg(:red).bold.underline
  end

  def test_just_code
    assert_equal "\e[0m", Ansi256.reset
    assert_equal "\e[1m", Ansi256.bold
    assert_equal "\e[4m", Ansi256.underline

    assert_equal "\e[30m", Ansi256.black
    assert_equal "\e[31m", Ansi256.red
    assert_equal "\e[32m", Ansi256.green
    assert_equal "\e[33m", Ansi256.yellow
    assert_equal "\e[34m", Ansi256.blue
    assert_equal "\e[35m", Ansi256.magenta
    assert_equal "\e[36m", Ansi256.cyan
    assert_equal "\e[37m", Ansi256.white

    assert_equal "\e[40m", Ansi256.on_black
    assert_equal "\e[41m", Ansi256.on_red
    assert_equal "\e[42m", Ansi256.on_green
    assert_equal "\e[43m", Ansi256.on_yellow
    assert_equal "\e[44m", Ansi256.on_blue
    assert_equal "\e[45m", Ansi256.on_magenta
    assert_equal "\e[46m", Ansi256.on_cyan
    assert_equal "\e[47m", Ansi256.on_white

    assert_equal "\e[30m", Ansi256.fg(:black)
    assert_equal "\e[31m", Ansi256.fg(:red)
    assert_equal "\e[32m", Ansi256.fg(:green)
    assert_equal "\e[33m", Ansi256.fg(:yellow)
    assert_equal "\e[34m", Ansi256.fg(:blue)
    assert_equal "\e[35m", Ansi256.fg(:magenta)
    assert_equal "\e[36m", Ansi256.fg(:cyan)
    assert_equal "\e[37m", Ansi256.fg(:white)

    assert_equal "\e[40m", Ansi256.bg(:black)
    assert_equal "\e[41m", Ansi256.bg(:red)
    assert_equal "\e[42m", Ansi256.bg(:green)
    assert_equal "\e[43m", Ansi256.bg(:yellow)
    assert_equal "\e[44m", Ansi256.bg(:blue)
    assert_equal "\e[45m", Ansi256.bg(:magenta)
    assert_equal "\e[46m", Ansi256.bg(:cyan)
    assert_equal "\e[47m", Ansi256.bg(:white)
  end

  def test_invalid_color_code
    assert_raises(ArgumentError) { Ansi256.fg(:none) }
    assert_raises(ArgumentError) { Ansi256.fg(:on_green) }
    assert_raises(ArgumentError) { Ansi256.bg(:none) }
    assert_raises(ArgumentError) { Ansi256.bg(:on_green) }
    assert_raises(ArgumentError) { Ansi256.fg(-1) }
    assert_raises(ArgumentError) { Ansi256.fg(300) }
    assert_raises(ArgumentError) { Ansi256.bg(-1) }
    assert_raises(ArgumentError) { Ansi256.bg(300) }
  end

  def test_fg_bg_underline
    assert_equal "\e[38;5;100mHello\e[0m", 'Hello'.fg(100)
    assert_equal "\e[48;5;100mHello\e[0m", 'Hello'.bg(100)

    assert_equal "\e[31mHello\e[0m", 'Hello'.red
    assert_equal "\e[41mHello\e[0m", 'Hello'.on_red

    assert_equal "\e[38;5;100mHello\e[38;5;200m world\e[0m", "#{'Hello'.fg(100)} world".fg(200)
    assert_equal "\e[38;5;200;4mWow \e[38;5;100mhello\e[38;5;200m world\e[0m",
      "Wow #{'hello'.fg(100)} world".fg(200).underline
    assert_equal "\e[38;5;200mWow \e[38;5;100;4mhello\e[0m\e[38;5;200m world\e[0m",
      "Wow #{'hello'.fg(100).underline} world".fg(200)
    assert_equal "\e[38;5;200mWow \e[38;5;100;48;5;50;4mhello\e[0m\e[38;5;200m world\e[0m",
      "Wow #{'hello'.fg(100).underline.bg(50)} world".fg(200)
    assert_equal "\e[38;5;200;48;5;250mWow \e[38;5;100;48;5;50;4mhello\e[0m\e[38;5;200;48;5;250m world\e[0m",
      "Wow #{'hello'.fg(100).underline.bg(50)} world".fg(200).bg(250)
    assert_equal "Wow hello world",
      "Wow #{'hello'.fg(100).underline.bg(50)} world".fg(200).bg(250).plain
  end
end
