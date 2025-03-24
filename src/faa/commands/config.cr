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
      def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
        # Check if --editor flag is present
        if options.has?("editor")
          edit_with_external_editor
        else
          edit_interactively
        end
      end

      private def edit_with_external_editor
        config_file = Faa::Configuration::File.new
        config_path = config_file.config_path.to_s
        
        # Create file if missing
        unless ::File.exists?(config_path)
          FileUtils.mkdir_p(::File.dirname(config_path))
          config_file.write(Faa::Configuration::Serialisable.new.to_json)
        end
        
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

        # Get validated values from user input
        active_path = prompt_with_validation(
          "Active Project Library path",
          current_config.active_project_library_path
        ) { |path| validate_directory(path, "Active Project Library") }
        
        working_path = prompt_with_validation(
          "Working Directory path",
          current_config.working_project_dir_path
        ) { |path| validate_directory(path, "Working Directory") }
        
        log_path = prompt_with_validation(
          "Log file path",
          current_config.log_file_path
        ) { |path| validate_parent_dir(path, "Log file") }

        # Update configuration
        current_config.overwrite!(active_path, working_path)
        current_config.serialisable.log_file = log_path
        current_config.save!

        context.display.success("Configuration updated successfully!")
      end

      def setup_ : Nil
        @name = "edit"
        @description = "Edit configuration file interactively or with external editor"
        
        add_option 'e', "editor", description: "Open in external editor instead of interactive mode"
      end

      private def prompt_with_validation(label : String, current : Path, &validator : String -> Bool) : String
        loop do
          input = context.input.request(
            "#{label}: [#{current}]",  # Clearer prompt format
            Display::Type::Info        # Ensure correct enum value
          ).try(&.strip) || ""

          value = input.empty? ? current.to_s : input
          
          if validator.call(value)
            return value
          end
        end
      end

      private def validate_directory(path : String, name : String) : Bool
        if ::Dir.exists?(path)
          true
        else
          context.display.warning("#{name} directory does not exist: #{path}")
          if context.input.yes?("Create directory now?")
            begin
              ::Dir.mkdir_p(path)
              true
            rescue ex
              context.display.error("Failed to create directory: #{ex.message}")
              false
            end
          else
            false
          end
        end
      end

      private def validate_parent_dir(path : String, name : String) : Bool
        parent = File.dirname(path)
        if ::Dir.exists?(parent)
          true
        else
          context.display.warning("Parent directory does not exist: #{parent}")
          if context.input.yes?("Create parent directory for #{name}?")
            begin
              ::Dir.mkdir_p(parent)
              true
            rescue ex
              context.display.error("Failed to create directory: #{ex.message}")
              false
            end
          else
            false
          end
        end
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
