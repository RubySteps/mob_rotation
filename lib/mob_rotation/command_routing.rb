module MobRotation
  module CommandRouting
    COMMAND_MAPPINGS = {}

    module ClassMethods
      def define_command(name, &block)
        CommandRouting::COMMAND_MAPPINGS[name] = block
      end
    end

    def command_router(command, mobster_names)
      command_implementation = CommandRouting::COMMAND_MAPPINGS.fetch(command) {
        lambda { |command|
          inform_lovely_user(command)
        }
      }
      case command_implementation.arity
      when -2
        instance_exec(command, *mobster_names, &command_implementation)
      when -1
        instance_exec(*mobster_names, &command_implementation)
      when 1
        instance_exec(command, &command_implementation)
      else
        instance_exec(&command_implementation)
      end
    end
  end
end
