require_relative 'advisor'
require_relative 'directional_support'

module Deciders
  module Advisors
    class Rester < Advisor
      MAX_HP = 20

      def call
        if should_rest?
          body.rest!
        end
      end

      private

      def should_rest?
        brain.health < MAX_HP && enemy_possibly_exists?
      end

      def enemy_possibly_exists?
        any_non_captive_units?
      end

      def any_non_captive_units?
        brain.listen.any? {|space| space.unit && !space.unit.is_a?(RubyWarrior::Units::Captive) }
      end
    end
  end
end
