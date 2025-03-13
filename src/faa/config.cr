require "yaml"
require "file_utils"
require "xdg"
require "log"

module Faa
  class Config
    class_property dir : ::String = XDG.app_config("faa_project")

    include YAML::Serializable

    property active_project_library : ::String? = nil

    property working_project_directory : ::String? = nil

    property log_level : Log::Severity = ::Log::Severity::Info

    property log_file : ::String? = nil

    def initialize
      @active_project_library ||= default_active_path.to_s
      @working_project_directory ||= default_working_path.to_s
      @log_file ||= default_log_file_path.to_s
    end

    # Add helper method to get concrete paths
    def active_project_library_path
      Path.new(@active_project_library.not_nil!)
    end

    def working_project_directory_path
      Path.new(@working_project_directory.not_nil!)
    end

    def log_file_path
      if path = log_file
        Path.new(path)
      else
        default_log_file_path
      end
    end

    def default_active_path
      Path.new("OneDrive - Federal Aviation Administration", "Active Project Library")
    end

    def default_working_path
      Path.home / "faa_workspace"
    end

    def default_log_file_path
      Path.new(XDG.state_home) / "faa_project/logs/faa.log"
    end

    def self.load : Config
      config_file = File.join(dir, "config.yml")

      if File.exists?(config_file)
        begin
          return from_yaml(File.read(config_file))
        rescue ex : YAML::ParseException
          Log.error { "Invalid config file: #{ex.message}" }
        end
      end

      new.tap(&.save)
    end

    def save
      FileUtils.mkdir_p(File.dirname(config_file))
      File.write(config_file, to_yaml)
    end

    private def config_file
      File.join(Config.dir, "config.yml")
    end
  end
end
