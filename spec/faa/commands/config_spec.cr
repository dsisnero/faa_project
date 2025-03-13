require "../../spec_helper"

describe Faa::Commands::Config::Edit do
  describe "interactive editing" do
    it "updates configuration with new values" do
      initial_config = {
        active_project_library: "/original/active",
        working_project_dir:    "/original/work",
        log_file:               "/original/log.log"
      }

      # Simulate user entering new values
      input = <<-INPUT
      /new/active
      /new/work
      /new/log.log
      INPUT

      with_config_file(initial_config) do |test_file|
        context = run_with_config(
          ["config", "edit"],
          stdin: IO::Memory.new(input),
          config_fixture: test_file
        )

        # Verify output
        output = context.stdout.to_s
        output.should contain("Active Project Library path:")
        output.should contain("Working Directory path:")
        output.should contain("Log file path:")
        output.should contain("Configuration updated successfully!")

        # Verify saved values
        updated = Faa::Configuration::Serialisable.from_json(test_file.read.not_nil!)
        updated.active_project_library_path.should eq(Path["/new/active"])
        updated.working_project_dir_path.should eq(Path["/new/work"])
        updated.log_file_path.should eq(Path["/new/log.log"])
      end
    end

    it "accepts default values on empty input" do
      initial_config = {
        active_project_library: "/default/active",
        working_project_dir:    "/default/work",
        log_file:               "/default/log.log"
      }

      # Simulate user pressing Enter 3 times
      input = "\n\n\n"

      with_config_file(initial_config) do |test_file|
        context = run_with_config(
          ["config", "edit"],
          stdin: IO::Memory.new(input),
          config_fixture: test_file
        )

        # Verify values remain unchanged
        updated = Faa::Configuration::Serialisable.from_json(test_file.read.not_nil!)
        updated.active_project_library_path.should eq(Path["/default/active"])
        updated.working_project_dir_path.should eq(Path["/default/work"])
        updated.log_file_path.should eq(Path["/default/log.log"])
      end
    end

    it "shows error for missing required inputs" do
      # No default values in empty config
      input = <<-INPUT
      
      
      
      INPUT

      with_config_file({} of String => String) do |test_file|
        context = run_with_config(
          ["config", "edit"],
          stdin: IO::Memory.new(input),
          config_fixture: test_file
        )

        # Verify error handling
        context.stdout.to_s.should contain("Invalid input - all fields are required")
        
        # Verify no changes persisted
        test_file.read.should be_nil
      end
    end
  end
end
