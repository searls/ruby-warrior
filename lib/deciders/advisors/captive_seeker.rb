require_relative 'walker'
require_relative 'directional_support'

module Deciders
  module Advisors
    class CaptiveSeeker < Walker
      include DirectionalSupport

      def call
        if dir = non_stairway_bearing_of(:captive)
          body.walk!(dir)
        end
      end
    end
  end
end
