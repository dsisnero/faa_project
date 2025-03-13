require "cling"
require "colorize"
require "./config"
require "./utils"
require "./logging"
require "./dir"

require "./commands/base"
require "./commands/*"

module Faa
  class App
    def self.run
      config = Config.load
      Logging.setup_logging(config)

      # Initialize core components with explicit dependencies
      faa_dir = Dir.new(
        config.active_project_library_path,
        config.working_project_directory_path
      )
      main = Commands::Main.new

      # Set up CLI commands

      # Parse arguments and run
      begin
        main.parse_and_run(ARGV)
      rescue ex
        main.on_error(ex)
      end
    end
  end
end
