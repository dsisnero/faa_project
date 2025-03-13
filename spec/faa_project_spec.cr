require "./spec_helper"

describe Faa do
  around_each do |test|
    original_config = Faa::Configuration::File::CONFIG_PATH
    test.run
    FileUtils.rm_rf(original_config) if File.exists?(original_config)
  end

  describe "core functionality" do
    it "initializes context with valid configuration" do
      context = run([] of String)
      
      # Verify default paths are set
      context.config.active_project_library_path.should eq(context.config.serialisable.default_active_path)
      context.config.working_project_dir_path.should eq(context.config.serialisable.default_working_path)
      context.stdout.to_s.should be_empty
    end

    it "handles invalid arguments in main command" do
      context = run(["invalid-command"])
      context.stdout.to_s.should contain("Unknown argument: invalid-command")
    end
  end
end
