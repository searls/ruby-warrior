module WarriorQueries
  MAX_HP = 20

  def restable?(warrior)
    warrior.health < MAX_HP && directions_for(warrior).none? {|dir| warrior.feel(dir).enemy? }
  end

  def attackable_direction(warrior)
    directions_for(warrior).find do |dir|
      warrior.feel(dir).enemy?
    end
  end

  def directions_for(warrior)
    [warrior.direction_of_stairs, :forward, :left, :right, :backward].uniq
  end
end

class ActMaybe

  def initialize(warrior, options)
    @warrior = warrior
    @command = options[:command]
    @query = options[:query]
  end

  def act
    if result = @query.call(@warrior)
      take_action(@warrior.method(@command), result)
      return true
    else
      return false
    end
  end

  private

  def take_action(method, *args)
    args = [] if method.name == :rest! #rest!'s reported arity is incorrect and will blow up at perform-turn-time

    method.call(*args.shift(method.arity.abs))
  end

end


class Player
  include WarriorQueries

  def play_turn(warrior)
    return if ActMaybe.new(warrior, :query => method(:restable?), :command => :rest!).act
    return if ActMaybe.new(warrior, :query => method(:attackable_direction), :command => :attack!).act

    warrior.walk!(warrior.direction_of_stairs)
  end
end


