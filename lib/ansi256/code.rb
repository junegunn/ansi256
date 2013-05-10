module Ansi256
  RESET = "\e[0m"

  CODE = {
    :reset      => 0,
    :bold       => 1,
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
  }
end
