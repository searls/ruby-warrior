require_relative 'advisor'
require_relative 'directional_support'

module Deciders
  module Advisors
    class BombThrower < Advisor
      include DirectionalSupport

      def call
        if direction = adjacent_enemy_cluster_direction
          body.detonate!(direction)
        end
      end

      private

      def adjacent_enemy_cluster_direction
        if clustered_enemy = adjacent(:enemy).find { |e| nearby?(e, :enemy) }
          brain.direction_of(clustered_enemy)
        end
      end

      def nearby?(search_space, space_type, within = 3)
        spaces(space_type).reject { |s| s == search_space }.select do |space|
          distance_between(search_space.location, space.location) <= within
        end.any?
      end

      def distance_between(a, b)
        Math.hypot(b[0]-a[0],b[1]-b[0]) #totally had to Google for this. shame on me.
      end
    end
  end
end
