module Faa
  class Configuration
    class Serialisable
      include JSON::Serializable

      def initialize
        @active_project_library ||= default_active_path.to_s
        @working_project_directory ||= default_working_path.to_s
        @log_file ||= default_log_file_path.to_s
      end

      getter active_project_library : ::String?
      getter working_project_directory : ::String?

      @[JSON::Field(emit_null: true)]
      property log_file : ::String?

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
    end
  end
end
