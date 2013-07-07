require_relative 'act_maybe'
require_relative 'warrior_queries'
require_relative 'warrior_commands'


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


