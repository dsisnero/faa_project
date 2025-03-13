require "log"
require "./log_formatter"
require "file_utils"

module Faa
  module Logging
    def self.setup_logging(config : Faa::Config)
      # Get config values
      log_level = config.log_level
      log_file = config.log_file

      if log_file
        # Create directory if needed
        FileUtils.mkdir_p(File.dirname(log_file))
        # Configure logging
        ::Log.setup(
          log_level,
          backend: ::Log::IOBackend.new(
            File.open(log_file, "a"),
            formatter: StdoutLogFormat
          )
        )

        ::Log.info { "Logging initialized".colorize.cyan }
      end
    end
  end
end
