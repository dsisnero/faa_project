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
        {% if flag?(:debug) %}
          raise(ex)
        {% else %}
          reason = "#{ex.class}: #{ex.message.try(&.split("\n").first)}"
          # TODO: Better handle this potential once-off case
          display.error("Invalid Config!", reason) do |sub_errors|
            sub_errors << "If you want to try and fix the config manually press Ctrl+C to quit\n"
            sub_errors << "Press enter if you want to proceed with a default config (this will override the existing config)"
          end
          gets # don't proceed unless user wants us to
          new(file)
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
