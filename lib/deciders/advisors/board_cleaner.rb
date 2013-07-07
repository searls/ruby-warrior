require_relative 'walker'
require_relative 'directional_support'

module Deciders
  module Advisors
    class BoardCleaner < Walker
      include DirectionalSupport

      def call
        if dir = unclean_direction
          body.walk!(dir)
        end
      end

      private

      def unclean_direction
        if anything_interesting? && adjacent_to_stairs?
          directions.shuffle.find do |dir|
            feel = brain.feel(dir)
            feel.empty? && !feel.stairs?
          end
        end
      end

      def anything_interesting?
        brain.listen.any? do |space|
          space.captive? || space.enemy?
        end
      end

      def adjacent_to_stairs?
        brain.feel(brain.direction_of_stairs).stairs?
      end
    end
  end
end
