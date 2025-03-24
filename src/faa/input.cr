require "term-prompt"

module Faa
  class Input
    @prompt : Term::Prompt

    def initialize(@stdin : IO, @display : Display)
      @prompt = Term::Prompt.new(
        input: @stdin,
        output: @display.stdout,
        symbols: {
          :success => "✓",
          :error   => "✗",
          :warning => "⚠",
          :info    => "➤"
        }
      )
    end

    def yes?(question : String) : Bool
      @prompt.yes?(question)
    end

    def no?(question : String) : Bool
      @prompt.no?(question)
    end

    def request(message : String, display_type : Display::Type? = nil, sensitive : Bool = false) : String?
      case display_type
      in Nil
        @display.puts(message)
      in .success?
        @display.success(message)
      in .warning?
        @display.warning(message)
      in .info?
        @display.info(message)
      in .warning?
        @display.warning(message)
      in .error?
        @display.error(message)
      in .fatal?
        @display.fatal!(message)
      end

      retrieve_input(sensitive) do
        gets.try(&.chomp).presence
      end
    end

    def request_or(message : String, display_type : Display::Type? = nil, sensitive : Bool = false, & : -> U) : String | U forall U
      request(message, display_type, sensitive) || yield
    end

    def request_and(message : String, display_type : Display::Type? = nil, sensitive : Bool = false, & : String? -> U) : String | U forall U
      yield(request(message, display_type, sensitive))
    end

    private def retrieve_input(sensitive : Bool, & : -> String?) : String?
      return yield unless sensitive

      STDIN.noecho do
        yield
      end
    end
  end
end
