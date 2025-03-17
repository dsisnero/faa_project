require "json"
require "file_utils"

require "./configuration/**"

module Faa
  class Configuration
    def self.init(file : Configuration::AbstractFile, display : Display) : Configuration
      config_contents = file.read.presence
      return new(file) unless config_contents

      begin
        new(file, Serialisable.from_json(config_contents))
      rescue ex : JSON::SerializableError | JSON::ParseException
        {% if flag?(:windows) %}
          raise(ex)
        {% else %}
          reason = "#{ex.class}: #{ex.message.try(&.split("\n").first)}"
          display.error("Invalid Config!", reason) do |sub_errors|
            sub_errors << "Press Enter to edit config now"
            sub_errors << "Press Ctrl+C to cancel"
          end

          if (input = gets) && input.chomp.empty? # User pressed Enter
            # Ensure file exists
            file.write(Serialisable.new.to_json) unless file.read.presence
            
            # Open editor
            editor = ENV["EDITOR"]? || "nano"
            Process.run(
              command: editor,
              args: [file.is_a?(File) ? file.config_path : "config.json"],
              input: STDIN,
              output: STDOUT,
              error: STDERR
            )

            # Recursively reload config after editing
            init(file, display)
          else
            new(file)
          end
        {% end %}
      rescue ex
        raise ex
      end
    end

    getter serialisable : Serialisable

    def initialize(@file : Configuration::AbstractFile, @serialisable = Serialisable.new); end

    delegate :active_project_library,
      :active_project_library_path,
      :working_project_dir,
      :working_project_dir_path,
      :log_file_path,
      to: @serialisable

    def overwrite!(active_project_library : String, working_project_dir : String)
      @serialisable.active_project_library = active_project_library
      @serialisable.working_project_dir = working_project_dir
      save!
    end

    def save!
      @file.write(@serialisable.to_json)
    end
  end
end
