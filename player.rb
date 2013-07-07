module WarriorQueries
  MAX_HP = 20
  DIRECTIONS = [:forward, :left, :right, :backward]

  def restable?
    warrior.health < MAX_HP && enemy_possibly_exists?
  end

  def attackable_direction
    direction_of(:enemy)
  end

  def attackable_bearing
    non_stairway_bearing_of(:enemy)
  end

  # If there are multiple unbound enemies surrounding me
  # Then I want to bind the ones in the direction I do not wish to travel
  def bindable_direction
    unbound_enemies = directions.select do |dir|
      feel = warrior.feel(dir)
      feel.enemy? && !feel.captive?
    end
    return unbound_enemies.last if unbound_enemies.size > 1
  end

  def rescuable_direction
    direction_of(:captive)
  end

  def rescuable_bearing
    non_stairway_bearing_of(:captive)
  end

  def uncleared_map_bearing
    if anything_interesting? && adjacent_to_stairs?
      DIRECTIONS.shuffle.find do |dir|
        feel = warrior.feel(dir)
        feel.empty? && !feel.stairs?
      end
    end
  end

  def cleared_map_bearing
    warrior.direction_of_stairs
  end

  private

  def adjacent_to_stairs?
    warrior.feel(warrior.direction_of_stairs).stairs?
  end

  def directions
    ([warrior.direction_of_stairs] + DIRECTIONS).uniq
  end

  def direction_of(space_type)
    directions.find do |dir|
      warrior.feel(dir).send("#{space_type}?")
    end
  end

  def non_stairway_bearing_of(space_type)
    bearings_of(space_type).find { |dir| !warrior.feel(dir).stairs? }
  end

  def bearings_of(space_type)
    warrior.listen.select(&("#{space_type}?".to_sym)).
      map {|space| warrior.direction_of(space) }
  end

  def bearing_of(space_type)
    bearings_of(space_type).first
  end

  def anything_interesting?
    warrior.listen.any? do |space|
      space.captive? || space.enemy?
    end
  end

  def enemy_possibly_exists?
    any_non_captive_units? || exists_but_only_at_a_distance?(:enemy)
  end

  def any_non_captive_units?
    warrior.listen.any? {|space| space.unit && !space.unit.is_a?(RubyWarrior::Units::Captive) }
  end

  def exists_but_only_at_a_distance?(space_type)
    !direction_of(space_type) && bearing_of(space_type)
  end
end

class ActMaybe

  def initialize(warrior, options)
    @warrior = warrior
    @command = options[:command]
    @query = options[:query]
  end

  def act
    if result = @query.call
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
  attr_reader :warrior

  ACTIONS = {
    bindable_direction: :bind!,
    attackable_direction: :attack!,
    restable?: :rest!,
    rescuable_direction: :rescue!
  }

  BEARINGS = [
    :rescuable_bearing,
    :attackable_bearing,
    :uncleared_map_bearing,
    :cleared_map_bearing
  ]

  def play_turn(warrior)
    @warrior = warrior

    ACTIONS.each do |(query, command)|
      return if act(warrior, query, command)
    end

    BEARINGS.each do |query|
      return if act(warrior, query, :walk!)
    end
  end
end


