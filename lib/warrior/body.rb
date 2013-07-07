module Warrior
  class Body
    def initialize(warrior)
      @warrior = warrior
    end

    def take_action
      @first_requested_action.call
    end

    def acted?
      @first_requested_action
    end

    def detonate!(dir)
      act!(:detonate!, dir)
    end

    def rescue!(dir)
      act!(:rescue!, dir)
    end

    def bind!(dir)
      act!(:bind!, dir)
    end

    def attack!(dir)
      act!(:attack!, dir)
    end

    def rest!
      act!(:rest!)
    end

    def walk!(dir)
      act!(:walk!, dir)
    end

    private

    def act!(action, *args)
      @first_requested_action = lambda { @warrior.send(action, *args) } unless acted?
    end
  end
end
