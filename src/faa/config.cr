require "yaml"
require "file_utils"
require "xdg"

module Faa
  class Config
    include YAML::Serializable

    @[YAML::Field]
    property active_project_library : String? = nil

    @[YAML::Field] 
    property working_project_directory : String? = nil

    def self.load : Config
      XDG.ensure_directories
      config_file = File.join(XDG.config_home, "faa_project", "config.yml")
      
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
      config_dir = File.join(XDG.config_home, "faa_project")
      FileUtils.mkdir_p(config_dir)
      File.write(File.join(config_dir, "config.yml"), to_yaml)
    end
  end
end
