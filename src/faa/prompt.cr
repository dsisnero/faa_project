module Faa
  class Prompt
    def ask(question : String, required : Bool = false) : String
      print "#{question} "
      answer = gets.try(&.strip) || ""

      if required && answer.empty?
        raise "Required field cannot be empty"
      end

      answer
    end
  end
end
