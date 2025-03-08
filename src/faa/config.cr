require "yaml"
require "file_utils"
require "xdg"

module Faa
  class Config
    class_getter(dir) { XDG.app_config("faa_project") }

    def self.dir
      XDG.app_config("faa_project")
    end

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

    private def default_active_path
      Path.home / "OneDrive - Federal Aviation Administration" / "Active Project Library"
    end

    private def default_working_path
      Path.home / "faa_workspace"
    end

    def self.load : Config
      XDG.ensure_directories
      config_file = File.join(Config.dir, "config.yml")

      if File.exists?(config_file)
        begin
          Config.from_yaml(File.read(config_file))
        rescue
          new.tap(&.save)
        end
      else
        new.tap(&.save)
      end
    end

    def save
      FileUtils.mkdir_p(Config.dir)
      File.write(File.join(Config.dir, "config.yml"), to_yaml)
    end
  end
end
