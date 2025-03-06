require "xdg"
require "yaml"
require "file_utils"

module Faa
  class Config
    include YAML::Serializable

    @[YAML::Field]
    property active_project_library : String? = nil

    @[YAML::Field]
    property working_project_directory : String? = nil

    def self.load : Config
      config_path = File.join(xdg_config_dir, "config.yml")
      
      if File.exists?(config_path)
        begin
          Config.from_yaml(File.read(config_path))
        rescue e
          new.tap(&.save) # Create new config if existing is corrupt
        end
      else
        new.tap(&.save)
      end
    end

    def save
      FileUtils.mkdir_p(File.dirname(config_path))
      File.write(config_path, to_yaml)
    end

    private def config_path
      File.join(self.class.xdg_config_dir, "config.yml")
    end

    private def self.xdg_config_dir : String
      XDG.config.find("faa_project").first.to_s.tap do |path|
        FileUtils.mkdir_p(path)
      end
    end
  end
end
