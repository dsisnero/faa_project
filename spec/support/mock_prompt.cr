class MockPrompt < Faa::Prompt
  property answers : Hash(String, String)
  property asked = [] of String

  def initialize(@answers = {} of String => String)
  end

  def ask(question : String, required : Bool = false) : String
    @asked << question
    answer = @answers.fetch(question) { "" }

    if required && answer.empty?
      raise "Required field #{question} cannot be empty"
    end

    answer
  end
end

def with_mocked_prompts(answers = {} of String => String, &block)
  # Get the original prompt and assert it's not nil
  original_prompt = Faa::Commands::Create.prompt.not_nil!
  
  Faa::Commands::Create.prompt = MockPrompt.new(answers)
  yield
ensure
  # Now safe to assign directly
  Faa::Commands::Create.prompt = original_prompt
end
