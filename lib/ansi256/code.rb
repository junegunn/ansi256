module Ansi256
  CODE = {
    :reset      => 0,
    :bold       => 1,
    :dim        => 2,
    :italic     => 3,
    :underline  => 4,

    :black      => 30,
    :red        => 31,
    :green      => 32,
    :yellow     => 33,
    :blue       => 34,
    :magenta    => 35,
    :cyan       => 36,
    :white      => 37,

    :on_black   => 40,
    :on_red     => 41,
    :on_green   => 42,
    :on_yellow  => 43,
    :on_blue    => 44,
    :on_magenta => 45,
    :on_cyan    => 46,
    :on_white   => 47,
  }.freeze

  NAMED_COLORS = Set[
   :black,
   :red,
   :green,
   :yellow,
   :blue,
   :magenta,
   :cyan,
   :white,
  ].freeze
end
