require_relative 'advisor'
require_relative 'directional_support'

module Deciders
  module Advisors
    class Rescuer < Advisor
      include DirectionalSupport
      def call
        if dir = direction_of(:captive)
          body.rescue!(dir)
        end
      end
    end
  end
end
