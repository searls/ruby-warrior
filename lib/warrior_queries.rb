module WarriorQueries
  MAX_HP = 20
  DIRECTIONS = [:forward, :left, :right, :backward]

  def restable?
    warrior.health < MAX_HP && enemy_possibly_exists?
  end

  def enemy_direction
    direction_of(:enemy)
  end

  def attackable_bearing
    non_stairway_bearing_of(:enemy)
  end

  # If there are multiple unbound enemies surrounding me
  # Then I want to bind the ones in the direction I do not wish to travel
  def additional_enemy
    unbound_enemies = directions.select do |dir|
      feel = warrior.feel(dir)
      feel.enemy? && !feel.captive?
    end
    return unbound_enemies.last if unbound_enemies.size > 1
  end

  def ticking_direction
    direction_of(:ticking)
  end

  def captive_direction
    direction_of(:captive)
  end

  def captive_bearing
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
