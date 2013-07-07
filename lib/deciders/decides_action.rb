require_relative 'decider'

require_relative 'advisors/captive_defuser'
require_relative 'advisors/bomb_thrower'
require_relative 'advisors/enemy_binder'
require_relative 'advisors/attacker'
require_relative 'advisors/rester'
require_relative 'advisors/rescuer'

module Deciders
  class DecidesAction < Decider
    def advisors
      [
        Advisors::CaptiveDefuser,
        Advisors::BombThrower,
        Advisors::EnemyBinder,
        Advisors::Attacker,
        Advisors::Rester,
        Advisors::Rescuer
      ]
    end
  end
end
