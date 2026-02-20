# frozen_string_literal: true

module Ansi256
  class << self
    def enabled= bool
      if bool
        String.class_eval do
          [:fg, :bg, :plain].each do |name|
            undef_method(name) if method_defined?(name)
          end

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
            undef_method(name) if method_defined?(name)
            define_method name do
              Ansi256.send name, self
            end
          end

          # Override underline to accept style and color
          undef_method(:underline) if method_defined?(:underline)
          define_method :underline do |*props|
            Ansi256.underline(self, *props)
          end
        end

        Ansi256.class_eval do
          class << self
            undef_method(:enabled?) if method_defined?(:enabled?)
            def enabled?
              true
            end
          end
        end
      else
        String.class_eval do
          [:fg, :bg, :plain].each do |name|
            undef_method(name) if method_defined?(name)
          end

          def fg code
            self
          end
          alias bg fg

          def plain
            Ansi256.plain self
          end

          Ansi256::CODE.each do |name, code|
            undef_method(name) if method_defined?(name)
            define_method name do
              self
            end
          end

          # Override underline to accept style and color (disabled mode)
          undef_method(:underline) if method_defined?(:underline)
          define_method :underline do |*props|
            self
          end
        end

        Ansi256.class_eval do
          class << self
            undef_method(:enabled?) if method_defined?(:enabled?)
            def enabled?
              false
            end
          end
        end
      end

      bool
    end
  end
end
