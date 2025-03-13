require "./abstract_file"

module Faa
  class Configuration
    class File < Configuration::AbstractFile
      CONFIG_DIR  = Path[XDG.config_home] / "faa_project"
      CONFIG_PATH = CONFIG_DIR / "config.json"

      def read : ::String?
        return unless CONFIG_PATH.exists?
        CONFIG_PATH.read
      end

      def write(content : ::String)
        FileUtils.mkdir_p(CONFIG_DIR) unless CONFIG_DIR.exists?
        CONFIG_PATH.write(content)
      end

      def close
        # no-op
      end
    end
  end
end
