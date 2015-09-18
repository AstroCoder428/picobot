# An implementation of a Picobot state machine.
#
# See https://www.cs.hmc.edu/csforall/index.html and
# https://www.cs.hmc.edu/picobot/ for more information.
module Picobot
  class Exception < ::StandardError
  end

  class RuleConflictError < Picobot::Exception
  end

  # A Picobot arena.
  class Arena
    attr_reader :max_x, :max_y

    def initialize(max_x, max_y)
      @max_x = max_x
      @max_y = max_y
      @touched = Array.new(max_x + 1) { [false] * (max_y + 1) }
    end

    def block(x, y)
      fail 'Out of bounds' unless include?(x, y)
      @touched[x][y] = nil
    end

    def include?(x, y)
      0 <= x && x <= max_x && 0 <= y && y <= max_y
    end

    def touch(x, y)
      fail 'Out of bounds' unless include?(x, y)
      @touched[x][y] = true
    end

    def touched?(x, y)
      @touched[x][y] == true
    end

    def finished?
      (max_x + 1).times do |x|
        (max_y + 1).times do |y|
          return false unless touched?(x, y) || blocked?(x, y)
        end
      end
      true
    end

    def blocked?(x, y)
      @touched[x][y].nil?
    end

    # Returns a hash mapping directions to a boolean indicating whether a block
    # is present.
    def bounds(x, y)
      Rule.motions.map do |k, (dx, dy)|
        rx = x + dx
        ry = y + dy
        [k, !include?(rx, ry) || blocked?(rx, ry)]
      end.to_h
    end
  end

  # A rule for the Picobot state machine.
  #
  # Each corresponding direction is true if it is blocked, and false if it is
  # unblocked.  This is consistent with the way Arena works.
  Rule = Struct.new(:start_state, :n, :e, :w, :s, :dir, :end_state) do
    def self.parse(rule)
      res = /^(\d+) ([x*N][x*E][x*W][x*S]) -> ([NEWSX]) (\d+)$/.match rule
      fail 'Invalid rule' unless res
      mapping = {
        :N => true, :E => true, :S => true, :W => true,
        :* => nil,
        :x => false
      }
      modes = res[2].each_char.map { |c| mapping[c.to_sym] }
      dir = mapping[res[3].to_sym] ? res[3].downcase.to_sym : :done
      new(res[1].to_i, *modes, dir, res[4].to_i)
    end

    def self.motions
      { n: [0, -1], e: [1,  0], w: [-1, 0], s: [0,  1] }
    end

    def directions
      self.class.motions.keys
    end

    def ===(other)
      return false unless start_state == other.start_state
      directions.each do |sym|
        mine = method(sym).call
        theirs = other.method(sym).call
        return false if !mine.nil? && !theirs.nil? && mine != theirs
      end
      true
    end

    def to_s
      dirs = directions.map do |d|
        val = method(d).call
        val ? d.to_s.upcase : (val == false ? 'x' : '*')
      end.join('')
      "#{start_state} #{dirs} -> #{dir.to_s.upcase} #{end_state}"
    end

    def match?(state, now_n, now_e, now_w, now_s)
      return false unless start_state == state
      [
        [now_n, n],
        [now_e, e],
        [now_w, w],
        [now_s, s],
      ].each do |cur, pattern|
        return false unless cur == pattern || pattern.nil?
      end
      true
    end

    def move(bot)
      if dir == :done
        bot.done == true
      else
        bot.move(*self.class.motions[dir])
        bot.state = end_state
      end
    end
  end

  # A parser for Picobot state machine rules.
  class RuleParser
    def parse(rules)
      rules = rules.each_line.map { |l| do_parse(l) }.reject(&:nil?)
      validate(rules)
      rules
    end

    private

    def validate(rules)
      rules.each_with_index do |r1, i|
        rules[(i + 1)..rules.length].each do |r2|
          # rubocop:disable Style/CaseEquality
          fail RuleConflictError, "#{r1} conflicts with #{r2}" if r1 === r2
        end
      end
    end

    def do_parse(l)
      return if /^#/.match l
      return if /^\s*$/.match l
      Rule.parse(l)
    end
  end

  # An implementation of Picobot.
  class Bot
    attr_reader :x, :y, :done
    attr_accessor :state

    def initialize(arena, x, y)
      @arena = arena
      fail 'Bot is out of bounds' unless @arena.include?(x, y)
      @x = x
      @y = y
      @state = 0
      @done = false
    end

    def move(dx, dy)
      fail 'Out of bounds' unless @arena.include?(x + dx, y + dy)
      @x += dx
      @y += dy
      @arena.touch(@x, @y)
    end

    def done?
      @done
    end
  end

  # The Picobot state machine.
  class StateMachine
    attr_reader :log, :bot, :rules

    def initialize(arena, rules, start_x, start_y, options = {})
      @arena = arena
      @rules = RuleParser.new.parse rules
      @bot = Bot.new(arena, start_x, start_y)
      @log = [] if options[:log]
    end

    def run
      loop do
        break unless do_rules
      end
    end

    protected

    def do_rules
      bounds = @arena.bounds(@bot.x, @bot.y)
      @rules.each do |r|
        next unless r.match?(@bot.state, *bounds.values)
        @log << { bounds: bounds, x: @bot.x, y: @bot.y, rule: r } if @log
        r.move(@bot)
        return true
      end
      false
    end
  end
end
