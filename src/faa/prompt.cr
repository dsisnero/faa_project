module Faa
  class Prompt
    def ask(question : String, required : Bool = false) : String
      print "#{question} "
      answer = gets.try(&.strip) || ""
    end

    def error!(error_object : Error::Interface) : NoReturn
      error(error_object)
      Faa.exit!
    end

    def puts(message : String? = nil)
      @stdout.puts message
    end

    # Input methods
    def yes?(question : String) : Bool
      !!term_prompt.yes?(question)
    end

    def no?(question : String) : Bool
      !!term_prompt.no?(question)
    end

    def ask(message : String, &block : Term::Prompt::Question ->)
      term_prompt.ask(message, &block)
    end

    def ask(message : String)
      term_prompt.ask(message)
    end

    def select(message : String, choices, &block : Term::Prompt::List ->)
      term_prompt.select(message, choices, &block)
    end

    def select(message : String, choices)
      term_prompt.select(message, choices)
    end

    def multi_select(message : String, choices, &block : Term::Prompt::List ->)
      term_prompt.multi_select(message, choices, &block)
    end

    def multi_select(message : String, choices)
      term_prompt.multi_select(message, choices)
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

      answer
    end
  end
end
