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
  # Explicitly type the original prompt
  original_prompt : Faa::Prompt = Faa::Commands::Create.prompt
  
  Faa::Commands::Create.prompt = MockPrompt.new(answers)
  yield
ensure
  # Use not_nil! since we know this will be set
  Faa::Commands::Create.prompt = original_prompt.not_nil!
end
