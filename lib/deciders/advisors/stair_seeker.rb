require_relative 'walker'

module Deciders
  module Advisors
    class StairSeeker < Walker
      def call
        body.walk!(brain.direction_of_stairs)
      end
    end
  end
end
