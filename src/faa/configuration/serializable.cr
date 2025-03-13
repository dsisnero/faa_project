module Faa
  class Configuration
    class Serialisable
      include JSON::Serializable

      def initialize
        @active_project_library = default_active_path.to_s
        @working_project_dir = default_working_path.to_s
        @log_file = default_log_file_path.to_s
      end

      property active_project_library : ::String?
      property working_project_dir : ::String?

      @[JSON::Field(emit_null: true)]
      property log_file : ::String?

      # Add helper method to get concrete paths
      def active_project_library_path
        Path.new(@active_project_library || default_active_path.to_s)
      end

      def working_project_dir_path
        Path.new(@working_project_dir || default_working_path.to_s)
      end

      def log_file_path
        Path.new(@log_file || default_log_file_path.to_s)
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
