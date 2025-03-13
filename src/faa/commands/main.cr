require "./base"

module Faa::Commands
  class Main < Base
    def setup_ : Nil
      @name = "project_dir"
      @description = <<-DESC
      A CLI tool for working with Faa Projects and
      the Active Project Library
      DESC

      add_usage "faa_project <command> [options] <arguments>"

      add_commands(Config, Unzip, Create)
    end

    def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
      stdout.puts help_template
    end
  end
end
