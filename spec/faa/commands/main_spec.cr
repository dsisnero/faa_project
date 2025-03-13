require "../../spec_helper"

describe Faa::Commands::Main do
  describe "command execution" do
    it "shows help with --help flag" do
      context = run(["--help"])
      output = context.stdout.to_s
      output.should contain("Usage:")
      output.should contain("Available commands:")
    end

    it "executes config show command" do
      context = run(["config", "show"])
      output = context.stdout.to_s
      output.should contain("Active Project Library:")
      output.should contain("Working Directory:")
    end

    it "returns error for missing subcommand" do
      context = run(["config"])
      output = context.stdout.to_s
      output.should contain("Missing required argument")
    end
  end

  describe "error handling" do
    it "returns error code for invalid editor" do
      begin
        original_editor = ENV["EDITOR"]?
        ENV["EDITOR"] = "nonexistent_editor"

        context = run(["config", "edit"])
        output = context.stdout.to_s
        output.should contain("Error:")
      ensure
        ENV["EDITOR"] = original_editor
      end
    end

    it "handles configuration errors" do
      File.write(Faa::Configuration::File::CONFIG_PATH, "{invalid}")
      context = run(["config", "show"])
      context.stdout.to_s.should contain("Invalid Config!")
    end
  end
end
