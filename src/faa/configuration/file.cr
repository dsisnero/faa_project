require "./abstract_file"

module Faa
  class Configuration
    class File < Configuration::AbstractFile
      CONFIG_DIR  = XDG.app_config("faa_project")
      CONFIG_PATH = ::File.join(CONFIG_DIR , "config.json")

      def config_path
        CONFIG_PATH
      end

      def read : ::String?
        # Create directory if missing
        unless ::Dir.exists?(CONFIG_DIR)
          FileUtils.mkdir_p(CONFIG_DIR)
        end
        return unless ::File.exists?(CONFIG_PATH)
        ::File.read(CONFIG_PATH)
      end

      def write(content : ::String)
        # Ensure directory exists before writing
        FileUtils.mkdir_p(CONFIG_DIR) unless ::Dir.exists?(CONFIG_DIR)
        ::File.write(CONFIG_PATH, content)
      end

      def close
        # no-op
      end
    end
  end
end
