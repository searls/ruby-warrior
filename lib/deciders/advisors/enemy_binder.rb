require_relative 'advisor'
require_relative 'directional_support'

module Deciders
  module Advisors
    class EnemyBinder < Advisor
      include DirectionalSupport

      def call
        if dir = additional_enemy_direction
          body.bind!(dir)
        end
      end

      private

      def additional_enemy_direction
        adjacent_enemies = adjacent(:enemy)
        return brain.direction_of(adjacent_enemies.last) if adjacent_enemies.size > 1
      end
    end
  end
end
