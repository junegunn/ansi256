require "ansi256/version"
require "ansi256/code"
require "ansi256/mixin"
require 'set'

module Ansi256
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
    PATTERN = /\e\[[0-9;]+m/
    MULTI_PATTERN = /(?:\e\[[0-9;]+m)+/
    EMPTY_TRIPLE = [nil, nil, Set.new]

    def ansify prev, curr
      nums = []
      nums << curr[0] if prev[0] != curr[0]
      nums << curr[1] if prev[1] != curr[1]
      nums.concat curr[2].to_a if prev[2].proper_subset? curr[2]
      "\e[#{nums.compact.join ';'}m"
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
            reset
          else
            ''
          end + ansify(prev, current)
        end
      }
    end
  end
end

class String
  include Ansi256::Mixin
end

