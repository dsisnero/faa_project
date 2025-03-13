module Faa::Commands
  class Config < Base
    def setup_ : Nil
      @name = "config"
      @summary = "Configuration cmd"
      @description = "Setup, and edit project_dir configuration"

      add_commands(Edit, Show)
    end

    def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
      stdout.puts help_template
      exit 0
    end

    class Edit < Faa::Commands::Config
      def setup_ : Nil
        @name = "edit"
        @description = "Edit configuration file interactively"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        # Check if --editor flag is present
        if options.has?("editor")
          edit_with_external_editor
        else
          edit_interactively
        end
      end

      private def edit_with_external_editor
        config_path = Faa::Configuration::File::CONFIG_PATH
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

      private def edit_interactively
        current_config = context.config

        # Get new values from user input
        active_path = context.input.request(
          "Active Project Library path: [#{current_config.active_project_library_path}]",
          Display::Type::Info
        )
        
        working_path = context.input.request(
          "Working Directory path: [#{current_config.working_project_dir_path}]",
          Display::Type::Info
        )
        
        log_path = context.input.request(
          "Log file path: [#{current_config.log_file_path}]",
          Display::Type::Info
        )

        # Use existing values if user provided empty input
        active_path = active_path.presence || current_config.active_project_library
        working_path = working_path.presence || current_config.working_project_dir
        log_path = log_path.presence || current_config.log_file_path.to_s

        # Validate input - all fields are required
        if active_path.nil? || working_path.nil? || log_path.nil?
          context.display.error("Invalid input - all fields are required")
          return
        end

        # Update configuration
        current_config.overwrite!(active_path, working_path)
        current_config.serialisable.log_file = log_path
        current_config.save!

        context.display.success("Configuration updated successfully!")
      end

      def setup_ : Nil
        @name = "edit"
        @description = "Edit configuration file interactively or with external editor"
        
        add_option "e", "editor", description: "Open in external editor instead of interactive mode"
      end
    end

    class Show < Faa::Commands::Base
      def setup_ : Nil
        @name = "show"
        @description = "Display current configuration values"
      end

      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        config = context.config
        puts <<-CONFIG
           Active Project Library: #{config.active_project_library_path}
           Working Directory: #{config.working_project_dir_path}
           CONFIG
      end
    end
  end
end
