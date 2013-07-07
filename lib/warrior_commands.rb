module WarriorCommands
  def act(warrior, query_name, command_name)
    ActMaybe.new(warrior, :query => method(query_name), :command => command_name).act
  end
end
