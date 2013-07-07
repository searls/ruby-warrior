module Deciders
  class Decider
    def advisors
      raise 'Abstract Method'
    end

    def initialize
      @advisors = advisors.map(&:new)
    end

    def decide(brain, body)
      @advisors.each do |advisor|
        break if body.acted?
        advisor.suggest(brain, body)
      end
    end
  end
end
