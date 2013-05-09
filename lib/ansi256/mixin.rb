module Ansi256
  module Mixin
    def fg code
      Ansi256.fg(code, self)
    end

    def bg code
      Ansi256.bg(code, self)
    end

    def plain
      Ansi256.plain self
    end

    def underline
      Ansi256.underline self
    end
  end
end

