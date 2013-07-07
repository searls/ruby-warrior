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
