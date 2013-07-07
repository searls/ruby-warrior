require_relative 'walker'
require_relative 'directional_support'

module Deciders
  module Advisors
    class EnemySeeker < Walker
      include DirectionalSupport

      def call
        if dir = non_stairway_bearing_of(:enemy)
          body.walk!(dir)
        end
      end
    end
  end
end
