module WarriorQueries
  MAX_HP = 20

  def restable?(warrior)
    warrior.health < MAX_HP && exists_but_only_at_a_distance?(warrior, :enemy)
  end

  def attackable_direction(warrior)
    direction_of(warrior, :enemy)
  end

  def attackable_bearing(warrior)
    non_stairway_bearing_of(warrior, :enemy)
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
    direction_of(warrior, :captive)
  end

  def rescuable_bearing(warrior)
    non_stairway_bearing_of(warrior, :captive)
  end

  def point_of_interest_bearing(warrior)
    warrior.listen.select { |space| space.captive? || space.enemy? }.
      map { |space| warrior.direction_of(space) }.
      uniq.
      find { |dir| !warrior.feel(dir).stairs? }
  end

  def stairway_bearing(warrior)
    warrior.direction_of_stairs
  end

  private

  def directions_for(warrior)
    [warrior.direction_of_stairs, :forward, :left, :right, :backward].uniq
  end

  def direction_of(warrior, space_type)
    directions_for(warrior).find do |dir|
      warrior.feel(dir).send("#{space_type}?")
    end
  end

  def exists_but_only_at_a_distance?(warrior, space_type)
    !direction_of(warrior, space_type) && bearing_of(warrior, space_type)
  end

  def non_stairway_bearing_of(warrior, space_type)
    if bearing = bearing_of(warrior, space_type)
      return bearing unless warrior.feel(bearing).stairs?
    end
  end

  def bearing_of(warrior, space_type)
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
    :attackable_bearing,
    :point_of_interest_bearing,
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


