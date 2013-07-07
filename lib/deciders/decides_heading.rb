require_relative 'decider'

require_relative 'advisors/captive_seeker'
require_relative 'advisors/enemy_seeker'
require_relative 'advisors/board_cleaner'
require_relative 'advisors/stair_seeker'

module Deciders
  class DecidesHeading < Decider
    def advisors
      [
        Advisors::CaptiveSeeker,
        Advisors::EnemySeeker,
        Advisors::BoardCleaner,
        Advisors::StairSeeker
      ]
    end
  end
end
