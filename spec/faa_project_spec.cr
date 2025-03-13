require "./spec_helper"

describe Faa do

  describe "core functionality" do
    it "initializes context with valid configuration" do
      with_config_file({
        "active_project_library" => "activelib",
        "working_project_dir" => "workinglib",
        "log_file" => "logfile"
      }) do |fixture|
        context = run_with_config([] of String, config_fixture: fixture)

        context.config.active_project_library_path.should eq(Path["activelib"])
        context.config.working_project_dir_path.should eq(Path["workinglib"])
        context.config.log_file_path.should eq(Path["logfile"])
        context.stdout.to_s.should be_empty
      end
    end

    it "handles invalid arguments in main command" do
      context = run(["invalid-command"])
      context.stdout.to_s.should contain("Unknown argument: invalid-command")
    end
  end
end
