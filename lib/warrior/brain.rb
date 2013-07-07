module Warrior
  class Brain
    extend Forwardable

    def_delegators :@warrior, :look, :health, :feel, :direction_of, :direction_of_stairs, :listen

    def initialize(warrior)
      @warrior = warrior
    end
  end
end
