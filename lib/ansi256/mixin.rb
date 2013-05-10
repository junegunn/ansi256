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

    Ansi256::CODE.each do |name, code|
      define_method name do
        Ansi256.send name, self
      end
    end
  end
end

