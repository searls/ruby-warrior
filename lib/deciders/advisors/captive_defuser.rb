require_relative 'advisor'
require_relative 'directional_support'

module Deciders
  module Advisors
    class CaptiveDefuser < Advisor
      include DirectionalSupport

      def call
        if dir = adjacent_ticking
          body.rescue!(dir)
        elsif dir = distant_ticking
          body.walk!(dir)
        end
      end

      private

      def adjacent_ticking
        direction_of(:ticking)
      end

      def distant_ticking
        return unless exists_but_only_at_a_distance?(:ticking)
        ticking_captives = spaces(:ticking)
        dir = brain.direction_of(ticking_captives.first)
        if brain.feel(dir).empty?
          dir
        elsif way_around = directions_around(dir).find {|dir| brain.feel(dir).empty? }
          way_around
        end
      end

      def exists_but_only_at_a_distance?(space_type)
        !direction_of(space_type) && bearing_of(space_type)
      end

      def directions_around(dir)
        directions - [dir, reverse(dir)]
      end

      def reverse(direction)
        case direction
          when :forward then :backward
          when :right then :left
          when :bottom then :forward
          when :left then :right
        end
      end
    end
  end
end
