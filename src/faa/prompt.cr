require "term-prompt"
require "./error/base"

module Faa
  class Prompt
    @term_prompt : Term::Prompt

    def initialize(@stdin : IO, @stdout : IO)
      @display = Display.new(@stdout)
      @term_prompt = Term::Prompt.new(
        input: @stdin.as(IO::FileDescriptor),
        output: @stdout.as(IO::FileDescriptor),
        symbols: {
          :success => "✓",
          :error   => "✗",
          :warning => "⚠",
          :info    => "➤"
        }
      )
    end

    # Display methods
    def success(message : String, value : String? = nil)
      @display.success(message, value)
    end

    def info(message : String, value : String? = nil)
      @display.info(message, value)
    end

    def warning(message : String)
      @display.warning(message)
    end

    def error(message : String, value : String? = nil)
      @display.error(message, value)
    end

    def error(error_object : Error::Interface)
      @display.error(error_object)
    end

    def error!(error_object : Error::Interface) : NoReturn
      @display.error(error_object)
      Faa.exit!
    end

    def fatal!(message : String) : NoReturn
      @display.fatal!(message)
    end

    def puts(message : String? = nil)
      @stdout.puts message
    end

    # Input methods
    def yes?(question : String) : Bool
      !!@term_prompt.yes?(question)
    end

    def no?(question : String) : Bool
      !!@term_prompt.no?(question)
    end

    def ask(question : String, required : Bool = false) : String
      print "#{question} "
      answer = gets.try(&.strip) || ""
      if required && answer.empty?
        error("A response is required")
        ask(question, required)
      else
        answer
      end
    end

    def ask(message : String, &block : Term::Prompt::Question ->)
      @term_prompt.ask(message, &block)
    end

    def ask(message : String)
      @term_prompt.ask(message)
    end

    def select(message : String, choices, &block : Term::Prompt::List ->)
      @term_prompt.select(message, choices, &block)
    end

    def select(message : String, choices)
      @term_prompt.select(message, choices)
    end

    def multi_select(message : String, choices, &block : Term::Prompt::List ->)
      @term_prompt.multi_select(message, choices, &block)
    end

    def multi_select(message : String, choices)
      @term_prompt.multi_select(message, choices)
    end

    # Legacy compatibility methods
    def request(message : String, display_type : Display::Type? = nil, sensitive : Bool = false) : String?
      case display_type
      in Nil
        puts(message)
      in .success?
        success(message)
      in .info?
        info(message)
      in .warning?
        warning(message)
      in .error?
        error(message)
      in .fatal?
        fatal!(message)
      end

      gets.try(&.chomp).presence
    end
  end
end
