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
  def bindable_direction(warrior)
    unbound_enemies = directions_for(warrior).select do |dir|
      feel = warrior.feel(dir)
      feel.enemy? && !feel.captive?
    end
    return unbound_enemies.last if unbound_enemies.size > 1
  end

  def rescuable_direction(warrior)
    immediate_direction_of(warrior, :captive)
  end

  def rescuable_bearing(warrior)
    distant_direction_of(warrior, :captive)
  end

  def stairway_bearing(warrior)
    warrior.direction_of_stairs
  end

  private

  def directions_for(warrior)
    [warrior.direction_of_stairs, :forward, :left, :right, :backward].uniq
  end

  def immediate_direction_of(warrior, space_type)
    directions_for(warrior).find do |dir|
      warrior.feel(dir).send("#{space_type}?")
    end
  end

  def distant_direction_of(warrior, space_type)
    warrior.listen.select(&("#{space_type}?".to_sym)).
      map {|space| warrior.direction_of(space) }.
      first
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

  ACTIONS = {
    bindable_direction: :bind!,
    attackable_direction: :attack!,
    restable?: :rest!,
    rescuable_direction: :rescue!
  }

  BEARINGS = [
    :rescuable_bearing,
    :stairway_bearing
  ]

  def play_turn(warrior)
    ACTIONS.each do |(query, command)|
      return if act(warrior, query, command)
    end

    BEARINGS.each do |query|
      return if act(warrior, query, :walk!)
    end
  end
end


