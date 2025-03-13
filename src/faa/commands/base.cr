require "cling"
require "./help"

module Faa
  module Commands
    abstract class Base < Cling::Command
      def initialize(@context : Context)
        super(stdout: @context.stdout)
      end

      getter context : Context
      delegate client, config, current, stdout, display, input, to: context

      abstract def setup_
      abstract def run_(arguments : Cling::Arguments, options : Cling::Options)

      # overrides Cling::Command#add_commands
      def add_commands(*commands : Base.class)
        commands.each do |klass|
          add_command(klass.new(context))
        end
      end

      # override this to extend `pre_run` behaviour
      def before_run(arguments : Cling::Arguments, options : Cling::Options) : Bool
        true
      end

      def setup : Nil
        setup_

        help_command = Help.new(stdout)
        add_option long: "no-colour", description: "Disable ANSI colours"
        add_option 'h', help_command.name, description: help_command.description
        add_command(help_command)
      end

      def pre_run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        handle_maybe_no_colour(options)

        return if help?(arguments, options)

        before_run(arguments, options)
      end

      def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        if help?(arguments, options)
          help_command.run(arguments, options)
        else
          run_(arguments, options)
        end
      end

      # A hook method for when the command raises an exception during execution
      def on_error(ex : Exception)
        {% if flag?(:debug) %}
          puts "in debug mode"
          super
        {% else %}
          display.error(ex.message || "An error occurred")
          stdout.puts help_template
          Faa.exit(1)
        {% end %}
      end

      # A hook method for when the command receives missing arguments during execution
      def on_missing_arguments(arguments : Array(::String))
        display.error("Missing required argument#{"s" if arguments.size > 1}: #{arguments.join(", ")}")
        stdout.puts help_template
        Faa.exit(1)
      end

      # A hook method for when the command receives unknown arguments during execution
      def on_unknown_arguments(arguments : Array(::String))
        display.error("Unknown argument#{"s" if arguments.size > 1}: #{arguments.join(", ")}")
        stdout.puts help_template
        Faa.exit(1)
      end

      # A hook method for when the command receives an invalid option, for example, a value given to
      # an option that takes no arguments
      def on_invalid_option(message : ::String)
        display.error(message)
        stdout.puts help_template
        Faa.exit(1)
      end

      # A hook method for when the command receives missing options that are required during
      # execution
      def on_missing_options(options : Array(::String))
        display.error("Missing required option#{"s" if options.size > 1}: #{options.join(", ")}")
        stdout.puts help_template
        Faa.exit(1)
      end

      # A hook method for when the command receives unknown options during execution
      def on_unknown_options(options : Array(::String))
        display.error("Unknown option#{"s" if options.size > 1}: #{options.join(", ")}")
        stdout.puts help_template
        Faa.exit(1)
      end

      private def handle_maybe_no_colour(options : Cling::Options)
        return unless options.has?("no-colour")

        Colorize.enabled = false
      end

      private def help?(arguments : Cling::Arguments, options : Cling::Options) : Bool
        arguments.has?("help") || options.has?("help")
      end

      private def help_command : Cling::Command
        children["help"]
      end
    end
  end
end
