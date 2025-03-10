module Faa::Commands
  class Config < Base
    def setup : Nil
      @name = "config"
      @summary = "Configuration cmd"
      @description = "Setup, and edit project_dir configuration"

      add_command Commands::Config::Edit.new
      add_command Commands::Config::Show.new
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      stdout.puts help_template
      exit 0
    end

    class Edit < Faa::Commands::Config
      def setup : Nil
        @name = "edit"
        @description = "Edit configuration file in default editor"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        config_path = File.join(Faa::Config.dir, "config.yml")
        editor = ENV["EDITOR"]? || "nano" # Default to nano if $EDITOR not set

        puts "Opening config file: #{config_path}"
        Process.run(
          command: editor,
          args: [config_path],
          input: STDIN,
          output: STDOUT,
          error: STDERR
        )
      end
    end

    class Show < Faa::Commands::Config
      def setup : Nil
        @name = "show"
        @description = "Display current configuration values"
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        config = Faa::Config.load
        puts <<-CONFIG
           Active Project Library: #{config.active_project_library_path}
           Working Directory: #{config.working_project_directory_path}
           CONFIG
      end
    end
  end
end
