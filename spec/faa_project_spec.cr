require "./spec_helper"

describe Faa do
  describe "core functionality" do
    it "initializes context with valid configuration" do
      context = run([] of String)
      context.config.should be_a(Faa::Configuration)
      context.stdout.to_s.should be_empty
    end

    it "handles invalid arguments in main command" do
      context = run(["invalid-command"])
      context.stdout.to_s.should contain("Unknown argument: invalid-command")
    end
  end
end
