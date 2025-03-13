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
      
      # Set up CLI commands
      cli = Commands::Base.new
      cli.name = "main"
      cli.description = <<-DESC
      A CLI tool for working with Faa Projects and
      the Active Project Library
      DESC

      cli.add_usage "faa <command> [options] <arguments>"

      cli.add_command Commands::Config.new
      cli.add_command Commands::Unzip.new
      cli.add_command Commands::Create.new(faa_dir)
      
      # Parse arguments and run
      begin
        cli.parse_and_run(ARGV)
      rescue ex
        cli.on_error(ex)
      end
    end
  end
end
