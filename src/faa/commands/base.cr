require "term-prompt"

module Faa
  module Commands
    abstract class Base < Cling::Command
      getter(prompt) { Term::Prompt.new }

      def initialize
        super

        @inherit_options = true
        @debug = false
        add_option "debug", description: "print debug information"
        add_option "no-color", description: "disable ansi color codes"
        add_option 'h', "help", description: "get help information"
      end

      def help_template : String
        String.build do |io|
          io << "Usage".colorize.blue << '\n'
          @usage.each do |use|
            io << "• " << use << '\n'
          end
          io << '\n'

          unless @children.empty?
            io << "Commands".colorize.blue << '\n'
            max_size = 4 + @children.keys.max_of &.size

            @children.each do |name, command|
              io << "• " << name.colorize.bold
              if summary = command.summary
                io << " " * (max_size - name.size)
                io << summary
              end
              io << '\n'
            end

            io << '\n'
          end

          io << "Options".colorize.blue << '\n'
          max_size = 4 + @options.each.max_of { |name, opt| name.size + (opt.short ? 2 : 0) }

          @options.each do |name, option|
            if short = option.short
              io << '-' << short << ", "
            end
            io << "--" << name

            if description = option.description
              name_size = name.size + (option.short ? 4 : 0)
              io << " " * (max_size - name_size)
              io << description
            end
            io << '\n'
          end
          io << '\n'

          io << "Description".colorize.blue << '\n'
          io << @description
        end
      end

      def pre_run(arguments : Cling::Arguments, options : Cling::Options) : Nil
        @debug = true if options.has? "debug"
        Colorize.enabled = false if options.has? "no-color"

        if options.has? "help"
          stdout.puts help_template
          exit 0
        end
      end

 protected def puts : Nil
      stdout.puts
    end

    protected def puts(msg : String) : Nil
      stdout.puts msg
    end

    protected def info(msg : String) : Nil
      stdout << "» " << msg << '\n'
    end

    protected def success(msg : String) : Nil
      stdout << "» Success".colorize.green << ": " << msg << '\n'
    end

    protected def warn(msg : String) : Nil
      stdout << "» Warning".colorize.yellow << ": " << msg << '\n'
    end

    protected def warn(*args : String) : Nil
      stdout << "» Warning".colorize.yellow << ": " << args[0] << '\n'
      args[1..].each { |arg| stdout << "»  ".colorize.yellow << arg << '\n' }
    end

    protected def error(msg : String) : Nil
      stderr << "» Error".colorize.red << ": " << msg << '\n'
    end

    protected def error(*args : String) : Nil
      stderr << "» Error".colorize.red << ": " << args[0] << '\n'
      args[1..].each { |arg| stderr << "»  ".colorize.red << arg << '\n' }
    end

    protected def fatal(*args : String) : NoReturn
      error *args
      exit_program
    end

      def on_error(ex : Exception)
        case ex
        when Cling::CommandError
          error ex.message
          error "See '#{"project_dir --help".colorize.blue}' for more information"
        when Faa::Error
          error ex.message
          # TODO: "See 'project_dir help query' for more information"
        else
          error "Unexpected exception:"
          error ex.message
          error "Please report this on the project_dir GitHub issues:"
          error "https://github.com/dsisnero/project_dir/issues"
        end

        if @debug
          debug "loading stack trace..."

          stack = ex.backtrace || %w[???]
          stack.each { |line| debug " " + line }
        end

        exit 1
      end

      def on_missing_arguments(args : Array(String))
        command = "project_dir #{name} --help".colorize.blue
        error "Missing required argument#{"s" if args.size > 1}:"
        error " #{args.join(", ")}"
        error "See '#{command}' for more information"
        exit 1
      end

      def on_unknown_arguments(args : Array(String))
        command = %(project_dir #{name == "main" ? "" : name + " "}--help).colorize.blue
        error "Unexpected argument#{"s" if args.size > 1} for this command:"
        error " #{args.join ", "}"
        error "See '#{command}' for more information"
        exit 1
      end

      def on_unknown_options(options : Array(String))
        command = %(project_dir #{name == "main" ? "" : name + " "}--help).colorize.blue
        error "Unexpected option#{"s" if options.size > 1} for this command:"
        error " #{options.join ", "}"
        error "See '#{command}' for more information"
        exit 1
      end
    end
  end
end
