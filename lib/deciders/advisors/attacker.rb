require_relative 'advisor'
require_relative 'directional_support'

module Deciders
  module Advisors
    class Attacker < Advisor
      include DirectionalSupport

      def call
        if dir = direction_of(:enemy)
          body.attack!(dir)
        end
      end
    end
  end
end
