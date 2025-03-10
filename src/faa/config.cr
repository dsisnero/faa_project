require "yaml"
require "file_utils"
require "xdg"
require "log"

module Faa
  class Config
    class_property dir : String = XDG.app_config("faa_project")

    include YAML::Serializable

    @[YAML::Field]
    property active_project_library : String? = nil

    @[YAML::Field]
    property working_project_directory : String? = nil

    def initialize
      @active_project_library ||= File.join(Path.home, "OneDrive - Federal Aviation Administration", "Active Project Library")
      @working_project_directory ||= File.join(Path.home, "faa_workspace")
    end

    # Add helper method to get concrete paths
    def active_project_library_path
      Path.new(@active_project_library || default_active_path)
    end

    def working_project_directory_path
      Path.new(@working_project_directory || default_working_path)
    end

    def default_active_path
      Path.home / "OneDrive - Federal Aviation Administration" / "Active Project Library"
    end

    def default_working_path
      Path.home / "faa_workspace"
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
