require 'set'
require 'ansi256/version'
require 'ansi256/code'
require 'ansi256/mixin'

module Ansi256
  class << self
    def fg code, str = nil
      if str
        wrap str, Ansi256.fg(code)
      elsif NAMED_COLORS.include?(code)
        "\e[#{CODE[code]}m"
      elsif code.is_a?(Integer) && (0..255).include?(code)
        "\e[38;5;#{code}m"
      elsif ansirgb = ansicode_for_rgb(code)
        "\e[38;5;#{ansirgb}m"
      else
        raise ArgumentError, "Invalid color code: #{code}"
      end
    end

    def bg code, str = nil
      if str
        wrap str, Ansi256.bg(code)
      elsif NAMED_COLORS.include?(code)
        "\e[#{CODE[code] + 10}m"
      elsif code.is_a?(Integer) && (0..255).include?(code)
        "\e[48;5;#{code}m"
      elsif ansirgb = ansicode_for_rgb(code)
        "\e[48;5;#{ansirgb}m"
      else
        raise ArgumentError, "Invalid color code: #{code}"
      end
    end

    CODE.each do |name, code|
      define_method name do |*arg|
        if str = arg.first
          wrap str, "\e[#{code}m"
        else
          "\e[#{code}m"
        end
      end
    end

    def plain str
      str.gsub(PATTERN, '')
    end

  private
    PATTERN       = /\e\[[0-9;]+m/.freeze
    MULTI_PATTERN = /(?:\e\[[0-9;]+m)+/.freeze
    EMPTY_TRIPLE  = [nil, nil, Set.new].freeze

    def ansify prev, curr
      nums = []
      nums << curr[0] if prev[0] != curr[0]
      nums << curr[1] if prev[1] != curr[1]
      nums.concat curr[2].to_a if prev[2] != curr[2]
      "\e[#{nums.compact.join ';'}m"
    end

    def ansicode_for_rgb rgb
      return unless rgb.is_a?(String) &&
                    rgb =~ /^#?([0-9a-f]+)$/i
      rgb = $1

      case rgb.length
      when 2
        m = (256 - 231) * rgb.to_i(16) / 256
        return m == 0 ? 16 : (231 + m)
      when 3
        r, g, b = rgb.each_char.map { |e| (e * 2).to_i(16) }
      when 6
        r, g, b = rgb.each_char.each_slice(2).map { |e| e.join.to_i(16) }
      else
        return
      end

      r, g, b = [r, g, b].map { |e| 6 * e / 256 }
      r * 36 + g * 6 + b + 16
    end

    def wrap str, color
      current = [nil, nil, Set.new]

      (color + str.gsub(PATTERN) { |m|
        if m =~ /\e\[[^m]*\b0m/
          m + color
        else
          m
        end
      } << reset).gsub(MULTI_PATTERN) { |ansi|
        prev = current.dup
        prev[2] = prev[2].dup
        codes = ansi.scan(/\d+/).map(&:to_i)

        idx = -1
        while (idx += 1) < codes.length
          case code = codes[idx]
          when 38
            current[0] = codes[idx, 3].join ';'
            idx += 2 # 38;5;11
          when 48
            current[1] = codes[idx, 3].join ';'
            idx += 2 # 38;5;11
          when 30..37
            current[0] = codes[idx]
          when 40..47
            current[1] = codes[idx]
          when 0
            current[0] = current[1] = nil
            current[2].clear
          else
            current[2] << code
          end
        end

        if current == prev
          ''
        elsif current == EMPTY_TRIPLE
          reset
        else
          if (0..1).any? { |i| prev[i] && !current[i] } || current[2].proper_subset?(prev[2])
            prev = EMPTY_TRIPLE
            reset
          else
            ''
          end + ansify(prev, current)
        end
      }
    end
  end
end

Ansi256.enabled = true
