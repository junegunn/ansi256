# frozen_string_literal: true

$VERBOSE = true
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ansi256'
require 'minitest/autorun'

class TestAnsi256 < Minitest::Test
  def cfmt(col)
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
    puts world = 'World'.bg(226).fg(232).underline
    puts hello = "Hello #{world} !".fg(230).bg(75)
    puts say_hello_world = "Say '#{hello}'".fg(30)
    puts say_hello_world.plain.fg(27)
  end

  def test_nesting_hello_world2
    puts world = 'World'.bg(226).blue.underline
    puts hello = "Hello #{world} Hello".white.bold
    puts say_hello_world = "Say '#{hello}'".fg(30).underline
    puts say_hello_world.plain.fg(27)
  end

  def test_nesting_hello_world3
    puts world = 'World'.blue.underline
    puts hello = "Hello #{world} Hello".blue.bold
    puts say_hello_world = "Say '#{hello}'".fg(30).underline
    puts say_hello_world.plain.fg(27)
  end

  def test_named_colors
    s = 'Colorize me'
    puts [s.black,   s.black.bold,   s.white.bold.on_black].join ' '
    puts [s.red,     s.red.bold,     s.white.bold.on_red].join ' '
    puts [s.green,   s.green.bold,   s.white.bold.on_green].join ' '
    puts [s.yellow,  s.yellow.bold,  s.white.bold.on_yellow].join ' '
    puts [s.blue,    s.blue.bold,    s.white.bold.on_blue].join ' '
    puts [s.magenta, s.magenta.bold, s.white.bold.on_magenta].join ' '
    puts [s.cyan,    s.cyan.bold,    s.white.bold.on_cyan].join ' '
    puts [s.white,   s.white.bold,   s.white.bold.on_white].join ' '
  end

  def test_named_color_code_with_fg_bg
    puts 'Colorize me'.fg(:green).bg(:red).bold.underline
  end

  def test_just_code
    assert_equal "\e[0m", Ansi256.reset
    assert_equal "\e[1m", Ansi256.bold
    assert_equal "\e[2m", Ansi256.dim
    assert_equal "\e[3m", Ansi256.italic
    assert_equal "\e[4m", Ansi256.underline
    assert_equal "\e[7m", Ansi256.inverse
    assert_equal "\e[9m", Ansi256.strikethrough

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
    assert_raises(ArgumentError) { Ansi256.bg('ffaa') }
    assert_raises(ArgumentError) { Ansi256.bg('ffeeffaa') }
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
    assert_equal 'Wow hello world',
                 "Wow #{'hello'.fg(100).underline.bg(50)} world".fg(200).bg(250).plain

    assert_equal "\e[32;48;5;200;1mWow \e[38;5;100;44;1;4mhello\e[0m\e[32;48;5;200;1m world\e[0m",
                 "Wow #{'hello'.fg(100).underline.on_blue} world".green.bold.bg(200)
  end

  def test_rgb
    # Truecolor mode (default): 38;2;R;G;B
    {
      '00'     => [0, 0, 0],
      '000000' => [0, 0, 0],
      '111'    => [17, 17, 17],
      '11'     => [17, 17, 17],
      '101010' => [16, 16, 16],
      '1a'     => [26, 26, 26],
      '1a1a1a' => [26, 26, 26],
      '20'     => [32, 32, 32],
      '22'     => [34, 34, 34],
      '202020' => [32, 32, 32],
      '222222' => [34, 34, 34],
      'ff'     => [255, 255, 255],
      'ffffff' => [255, 255, 255],
      'FFFFFF' => [255, 255, 255],
      'ff0'    => [255, 255, 0],
      'ffff00' => [255, 255, 0],
      'ff0000' => [255, 0, 0],
      '00ff00' => [0, 255, 0],
      '0000ff' => [0, 0, 255],
      'ff9900' => [255, 153, 0],
      '00ffff' => [0, 255, 255],
      '0ff'    => [0, 255, 255],
    }.each do |hex, (r, g, b)|
      assert_equal "\e[38;2;#{r};#{g};#{b}m", Ansi256.fg(hex)
      assert_equal "\e[48;2;#{r};#{g};#{b}m", Ansi256.bg(hex)
    end
    # # prefix
    assert_equal "\e[38;2;255;153;0m", Ansi256.fg('#ff9900')
    assert_equal "\e[48;2;0;51;102m",  Ansi256.bg('#003366')

    # Visual output
    %i[bg fg].each do |m|
      (0..255).each do |r|
        color = r.to_s(16).rjust(2, '0') * 3
        print Ansi256.send(m, color, color + ' ')
      end
      (0..255).each do |r|
        color = r.to_s(16).rjust(2, '0')
        print Ansi256.send(m, color, color + ' ')
      end
    end
    0.step(255, 20) do |r|
      0.step(255, 20) do |g|
        0.step(255, 20) do |b|
          color = [r, g, b].map { |c| c.to_s(16).rjust(2, '0') }.join
          print Ansi256.bg(color, color + ' ')
        end
      end
    end
    puts 'RGB Color'.fg('ff9900').bg('003366')
    puts 'RGB Color'.fg('f90').bg('#036')
    puts 'RGB Color'.fg('#ff9900').bg('#003366')
    puts 'RGB Color (Monochrome)'.fg('ef').bg('3a')
  end

  def test_rgb_nesting
    # Truecolor inner nested inside truecolor outer
    assert_equal "\e[38;2;0;51;102mHello \e[38;2;255;153;0mWorld\e[38;2;0;51;102m !\e[0m",
                 "Hello #{'World'.fg('ff9900')} !".fg('003366')

    # Truecolor fg with integer bg
    assert_equal "\e[38;2;255;153;0;48;5;100mHello\e[0m",
                 'Hello'.fg('ff9900').bg(100)

    # Integer fg nested inside truecolor fg
    assert_equal "\e[38;2;0;51;102mHello \e[38;5;100mWorld\e[38;2;0;51;102m !\e[0m",
                 "Hello #{'World'.fg(100)} !".fg('003366')

    # Truecolor underline color in nesting
    inner = 'world'.underline(:curly, 'ff0000')
    result = "hello #{inner} end".fg('003366')
    assert_equal "\e[38;2;0;51;102mhello \e[4:3;58;2;255;0;0mworld\e[0m\e[38;2;0;51;102m end\e[0m", result
  end

  def test_rgb_approximation
    # When truecolor is disabled, fall back to 256-color approximation
    Ansi256.truecolor = false
    {
      '00'     => 16,
      '000000' => 16,
      '111'    => 16,
      '11'     => 232,
      '101010' => 16,
      '1a'     => 233,
      '1a1a1a' => 16,
      '20'     => 234,
      '22'     => 234,
      '202020' => 16,
      '222222' => 16,
      'ff'     => 255,
      'ffffff' => 231,
      'FFFFFF' => 231,
      'ff0'    => 226,
      'ffff00' => 226,
      'ff0000' => 196,
      '00ff00' => 46,
      '0000ff' => 21,
      'ff9900' => 214,
      '00ffff' => 51,
      '0ff'    => 51,
    }.each do |rgb, ansi|
      assert_equal ansi, Ansi256.fg(rgb).scan(/[0-9]+/).last.to_i
      assert_equal ansi, Ansi256.bg(rgb).scan(/[0-9]+/).last.to_i
    end
  ensure
    Ansi256.truecolor = true
  end

  def test_enabled
    2.times do
      %i[fg bg].each do |m|
        assert Ansi256.enabled?
        hello = 'hello'.send(m, 'f90')
        assert_equal 'hello', hello.plain

        Ansi256.enabled = false
        assert !Ansi256.enabled?
        assert hello.length > 'hello'.send(m, 'f90').length
        assert_equal 'hello', hello.plain

        Ansi256.enabled = true
        assert Ansi256.enabled?
        assert_equal hello, 'hello'.send(m, 'f90')
      end
    end
  end

  # --- Extended underline tests ---

  def test_underline_backward_compat
    # No-arg: returns SGR code
    assert_equal "\e[4m", Ansi256.underline

    # String arg: wraps with basic underline
    assert_equal "\e[4mhello\e[0m", Ansi256.underline('hello')
    assert_equal "\e[4mhello\e[0m", 'hello'.underline
  end

  def test_underline_styles
    assert_equal "\e[4:1mhello\e[0m", 'hello'.underline(:single)
    assert_equal "\e[4:2mhello\e[0m", 'hello'.underline(:double)
    assert_equal "\e[4:3mhello\e[0m", 'hello'.underline(:curly)
    assert_equal "\e[4:4mhello\e[0m", 'hello'.underline(:dotted)
    assert_equal "\e[4:5mhello\e[0m", 'hello'.underline(:dashed)
  end

  def test_underline_color_integer
    assert_equal "\e[58;5;214;4mhello\e[0m", 'hello'.underline(214)
  end

  def test_underline_color_hex
    assert_equal "\e[58;2;255;153;0;4mhello\e[0m", 'hello'.underline('ff9900')
    assert_equal "\e[58;2;255;153;0;4mhello\e[0m", 'hello'.underline('#ff9900')
    assert_equal "\e[58;2;255;153;0;4mhello\e[0m", 'hello'.underline('f90')
  end

  def test_underline_style_with_color
    assert_equal "\e[4:3;58;2;255;153;0mhello\e[0m", 'hello'.underline(:curly, 'ff9900')
    assert_equal "\e[4:2;58;5;100mhello\e[0m", 'hello'.underline(:double, 100)
  end

  def test_underline_invalid_style
    assert_raises(ArgumentError) { 'hello'.underline(:wavy) }
  end

  def test_underline_invalid_color
    assert_raises(ArgumentError) { 'hello'.underline(:curly, 'zzzzzz') }
    assert_raises(ArgumentError) { 'hello'.underline(:curly, -1) }
    assert_raises(ArgumentError) { 'hello'.underline(:curly, 256) }
  end

  def test_underline_style_nesting_with_fg
    # Styled underline nested inside fg color
    inner = 'world'.underline(:curly)
    result = "hello #{inner} end".fg(100)
    assert_equal "\e[38;5;100mhello \e[4:3mworld\e[0m\e[38;5;100m end\e[0m", result
  end

  def test_underline_color_nesting_with_fg
    inner = 'world'.underline(:curly, 196)
    result = "hello #{inner} end".fg(100)
    assert_equal "\e[38;5;100mhello \e[4:3;58;5;196mworld\e[0m\e[38;5;100m end\e[0m", result
  end

  def test_underline_disabled_mode
    Ansi256.enabled = false
    assert_equal 'hello', 'hello'.underline
    assert_equal 'hello', 'hello'.underline(:curly)
    assert_equal 'hello', 'hello'.underline(:curly, 'ff9900')
    assert_equal 'hello', 'hello'.underline(214)
    Ansi256.enabled = true
  end

  def test_underline_module_method_with_style
    assert_equal "\e[4:3mhello\e[0m", Ansi256.underline('hello', :curly)
    assert_equal "\e[4:3;58;2;255;153;0mhello\e[0m", Ansi256.underline('hello', :curly, 'ff9900')
    assert_equal "\e[58;5;214;4mhello\e[0m", Ansi256.underline('hello', 214)
  end

  def test_underline_named_color
    # Named color as sole argument (basic underline + color)
    assert_equal "\e[58;5;1;4mhello\e[0m", 'hello'.underline(:red)
    assert_equal "\e[58;5;4;4mhello\e[0m", 'hello'.underline(:blue)
    assert_equal "\e[58;5;0;4mhello\e[0m", 'hello'.underline(:black)
    assert_equal "\e[58;5;7;4mhello\e[0m", 'hello'.underline(:white)

    # Named color as second argument (style + color)
    assert_equal "\e[4:3;58;5;1mhello\e[0m", 'hello'.underline(:curly, :red)
    assert_equal "\e[4:2;58;5;4mhello\e[0m", 'hello'.underline(:double, :blue)

    # Swapped order: color first, style second
    assert_equal "\e[4:3;58;5;1mhello\e[0m", 'hello'.underline(:red, :curly)
    assert_equal "\e[4:2;58;5;4mhello\e[0m", 'hello'.underline(:blue, :double)
  end
end
