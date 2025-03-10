require "cling"
require "colorize"
require "./config"
require "./utils"

require "./commands/base"
require "./commands/*"

module Faa
  class App < Commands::Base
    def setup : Nil
      @name = "main"
      @description = <<-DESC
      A CLI tool for working with Faa Projects and
      the Active Project Library
      DESC

      add_usage "project_dir <command> [options] <arguments>"

      add_command Commands::Config.new
      add_command Commands::Unzip.new
      add_command Commands::Create.new
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      stdout.puts help_template
    end
  end
end
