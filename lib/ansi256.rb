# frozen_string_literal: true

require 'set'
require 'ansi256/version'
require 'ansi256/code'
require 'ansi256/mixin'

module Ansi256
  class << self
    attr_accessor :truecolor

    def fg(code, str = nil)
      if str
        wrap str, Ansi256.fg(code)
      elsif NAMED_COLORS.include?(code)
        "\e[#{CODE[code]}m"
      elsif code.is_a?(Integer) && (0..255).include?(code)
        "\e[38;5;#{code}m"
      elsif rgb = parse_rgb(code)
        if truecolor
          "\e[38;2;#{rgb.join(';')}m"
        else
          "\e[38;5;#{ansicode_for_rgb(code)}m"
        end
      else
        raise ArgumentError, "Invalid color code: #{code}"
      end
    end

    def bg(code, str = nil)
      if str
        wrap str, Ansi256.bg(code)
      elsif NAMED_COLORS.include?(code)
        "\e[#{CODE[code] + 10}m"
      elsif code.is_a?(Integer) && (0..255).include?(code)
        "\e[48;5;#{code}m"
      elsif rgb = parse_rgb(code)
        if truecolor
          "\e[48;2;#{rgb.join(';')}m"
        else
          "\e[48;5;#{ansicode_for_rgb(code)}m"
        end
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

    # Override underline to support styles and colors
    def underline(str = nil, *props)
      if str.nil?
        build_underline_sgr(*props)
      else
        wrap str, build_underline_sgr(*props)
      end
    end

    def plain(str)
      str.gsub(PATTERN, '')
    end

    private

    PATTERN       = /\e\[[0-9;:]+m/
    MULTI_PATTERN = /(?:\e\[[0-9;:]+m)+/
    # State: [fg, bg, ul_style, ul_color, attrs_set]
    # ul_style is only for sub-parameter styles (4:1, 4:2, etc.)
    # Basic underline (4) stays in attrs_set for backward compat
    EMPTY_STATE   = [nil, nil, nil, nil, Set.new].freeze

    def build_underline_sgr(*args)
      style = nil
      color = nil

      args.each do |arg|
        case arg
        when nil
          next
        when Symbol
          if UNDERLINE_STYLES[arg]
            style = arg
          elsif NAMED_COLORS.include?(arg)
            color = arg
          else
            raise ArgumentError, "Invalid underline argument: #{arg}"
          end
        when Integer, String
          color = arg
        else
          raise ArgumentError, "Invalid underline argument: #{arg}"
        end
      end

      return "\e[4m" unless style || color

      parts = []
      parts << (style ? UNDERLINE_STYLES[style] : '4')
      parts << underline_color_code(color) if color

      "\e[#{parts.join(';')}m"
    end

    def underline_color_code(color)
      case color
      when Symbol
        raise ArgumentError, "Invalid underline color: #{color}" unless NAMED_COLORS.include?(color)
        "58;5;#{CODE[color] - 30}"
      when Integer
        raise ArgumentError, "Invalid underline color: #{color}" unless (0..255).include?(color)
        "58;5;#{color}"
      when String
        rgb = parse_rgb(color)
        raise ArgumentError, "Invalid underline color: #{color}" unless rgb
        if truecolor
          "58;2;#{rgb.join(';')}"
        else
          "58;5;#{ansicode_for_rgb(color)}"
        end
      else
        raise ArgumentError, "Invalid underline color: #{color}"
      end
    end

    def ansify(prev, curr)
      nums = []
      nums << curr[0] if prev[0] != curr[0]
      nums << curr[1] if prev[1] != curr[1]
      nums << curr[2] if prev[2] != curr[2]
      nums << curr[3] if prev[3] != curr[3]
      nums.concat curr[4].to_a if prev[4] != curr[4]
      "\e[#{nums.compact.join ';'}m"
    end

    def parse_rgb(code)
      return unless code.is_a?(String) &&
                    code =~ /^#?([0-9a-f]+)$/i

      hex = ::Regexp.last_match(1)

      case hex.length
      when 2
        v = hex.to_i(16)
        [v, v, v]
      when 3
        hex.each_char.map { |e| (e * 2).to_i(16) }
      when 6
        hex.each_char.each_slice(2).map { |e| e.join.to_i(16) }
      end
    end

    def rgb_to_ansi256(r, g, b)
      r, g, b = [r, g, b].map { |e| 6 * e / 256 }
      r * 36 + g * 6 + b + 16
    end

    def ansicode_for_rgb(code)
      return unless code.is_a?(String) &&
                    code =~ /^#?([0-9a-f]+)$/i

      hex = ::Regexp.last_match(1)

      # 2-char monochrome uses grayscale ramp (232-255)
      if hex.length == 2
        m = 25 * hex.to_i(16) / 256
        return m == 0 ? 16 : (231 + m)
      end

      rgb = parse_rgb(code)
      return unless rgb

      rgb_to_ansi256(*rgb)
    end

    def wrap(str, color)
      current = [nil, nil, nil, nil, Set.new]

      (color + str.gsub(PATTERN) do |m|
        if m == "\e[0m"
          m + color
        else
          m
        end
      end << reset).gsub(MULTI_PATTERN) do |ansi|
        prev = current.dup
        prev[4] = prev[4].dup

        # Extract individual SGR sequences and parse each
        seqs = ansi.scan(/\e\[([^\e]*?)m/).map { |cap| cap[0] }
        seqs.each do |seq|
          # Split by semicolon, preserving colon sub-params within groups
          groups = seq.split(';')

          idx = -1
          while (idx += 1) < groups.length
            group = groups[idx]

            if group.include?(':')
              # Sub-parameter group (e.g., "4:3")
              main, sub = group.split(':', 2)
              main_i = main.to_i
              if main_i == 4
                if sub == '0'
                  current[2] = nil
                  current[4].delete(4)
                else
                  current[2] = group
                  current[4].delete(4)
                end
              end
            else
              code = group.to_i
              case code
              when 38
                if groups[idx + 1] == '2'
                  current[0] = groups[idx, 5].join(';')
                  idx += 4
                else
                  current[0] = groups[idx, 3].join(';')
                  idx += 2
                end
              when 48
                if groups[idx + 1] == '2'
                  current[1] = groups[idx, 5].join(';')
                  idx += 4
                else
                  current[1] = groups[idx, 3].join(';')
                  idx += 2
                end
              when 58
                if groups[idx + 1] == '2'
                  current[3] = groups[idx, 5].join(';')
                  idx += 4
                else
                  current[3] = groups[idx, 3].join(';')
                  idx += 2
                end
              when 30..37
                current[0] = code
              when 40..47
                current[1] = code
              when 0
                current[0] = current[1] = current[2] = current[3] = nil
                current[4].clear
              when 24
                current[2] = nil
                current[4].delete(4)
              when 59
                current[3] = nil
              when 4
                # Basic underline goes in attrs set for backward compat
                current[4] << 4
              else
                current[4] << code
              end
            end
          end
        end

        if current == prev
          ''
        elsif current == EMPTY_STATE
          reset
        else
          if (0..3).any? { |i| prev[i] && !current[i] } || current[4].proper_subset?(prev[4])
            prev = EMPTY_STATE
            reset
          else
            ''
          end + ansify(prev, current)
        end
      end
    end
  end
end

Ansi256.enabled = true
Ansi256.truecolor = true
