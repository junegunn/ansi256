require "ansi256/version"
require "ansi256/mixin"

module Ansi256
  RESET = "\e[0m"

  class << self
    def fg code, str = nil
      if str
        wrap str, Ansi256.fg(code)
      else
        "\e[38;5;#{code}m"
      end
    end

    def bg code, str = nil
      if str
        wrap str, Ansi256.bg(code)
      else
        "\e[48;5;#{code}m"
      end
    end

    def underline str = nil
      if str
        wrap str, Ansi256.underline
      else
        "\e[4m"
      end
    end

    def reset
      RESET
    end

    def plain str
      str.gsub(PATTERN, '')
    end

  private
    PATTERN = /\e\[(?:[34]8;5;)?[0-9]+m/
    MULTI_PATTERN = /(?:\e\[(?:[34]8;5;)?[0-9]+m)+/

    def wrap str, color
      current = [nil, nil, nil]

      (color + str.gsub(PATTERN) { |m|
        if m =~ /\e\[0m/
          m + color
        else
          m
        end
      } << RESET).gsub(MULTI_PATTERN) { |codes|
        prev = current.dup
        codes.split(/(?<=m)/).each do |code|
          case code
          when /\e\[38/
            current[0] = code
          when /\e\[48/
            current[1] = code
          when /\e\[0m/
            current = [nil, nil, nil]
          else
            current[2] = code
          end
        end

        if current == prev
          ''
        elsif current == [nil, nil, nil]
          RESET
        else
          if (0..2).any? { |i| prev[i] && !current[i] }
            RESET
          else
            ''
          end + current.join
        end
      }
    end
  end
end

class String
  include Ansi256::Mixin
end

