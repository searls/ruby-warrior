require 'forwardable'

require_relative 'warrior/brain'
require_relative 'warrior/body'
require_relative 'deciders/decides_action'
require_relative 'deciders/decides_heading'

class Player
  def initialize()
    @deciders = [Deciders::DecidesAction, Deciders::DecidesHeading].map(&:new)
  end

  def play_turn(warrior)
    brain = Warrior::Brain.new(warrior)
    body = Warrior::Body.new(warrior)

    @deciders.each { |decider| decider.decide(brain, body) }

    body.take_action
  end
end


