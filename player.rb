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

  # If there are multiple unbound enemies surrounding me
  # Then I want to bind the ones in the direction I do not wish to travel
  def bind_direction(warrior)
    unbound_enemies = directions_for(warrior).select do |dir|
      feel = warrior.feel(dir)
      feel.enemy? && !feel.captive?
    end
    return unbound_enemies.last if unbound_enemies.size > 1
  end

  def captive_direction(warrior)
    directions_for(warrior).find do |dir|
      feel = warrior.feel(dir)
      feel.captive?
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

module WarriorCommands
  def act(warrior, query_name, command_name)
    ActMaybe.new(warrior, :query => method(query_name), :command => command_name).act
  end
end


class Player
  include WarriorQueries
  include WarriorCommands

  def play_turn(warrior)
    return if act(warrior, :bind_direction, :bind!)
    return if act(warrior, :attackable_direction, :attack!)
    return if act(warrior, :restable?, :rest!)
    return if act(warrior, :captive_direction, :rescue!)

    warrior.walk!(warrior.direction_of_stairs)
  end
end


