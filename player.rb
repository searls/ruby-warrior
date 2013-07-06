class Player
  def play_turn(warrior)
    return if ActMaybe.new(warrior, :query => method(:attackable_direction), :command => :attack!).act

    warrior.walk!(warrior.direction_of_stairs)
  end

  def attackable_direction(warrior)
    [warrior.direction_of_stairs, :forward, :left, :right, :backward].uniq.find do |dir|
      warrior.feel(dir).enemy?
    end
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
      @warrior.send(@command, result)
      return true
    end
    return false
  end


end
