module Deciders
  module Advisors
    module DirectionalSupport
      DIRECTIONS = [:forward, :left, :right, :backward]

      def direction_of(space_type)
        directions.find do |dir|
          brain.feel(dir).send("#{space_type}?")
        end
      end

      def directions
        ([brain.direction_of_stairs] + DIRECTIONS).uniq
      end

      def spaces(space_type)
        brain.listen.select(&("#{space_type}?".to_sym))
      end

      def adjacent(space_type)
        DIRECTIONS.map {|dir| brain.feel(dir) }.select do |space|
          space.send("#{space_type}?")
        end
      end

      def non_stairway_bearing_of(space_type)
        bearings_of(space_type).find { |dir| !brain.feel(dir).stairs? }
      end

      def bearings_of(space_type)
        spaces(space_type).map {|space| brain.direction_of(space) }
      end

      def bearing_of(space_type)
        bearings_of(space_type).first
      end
    end
  end
end
