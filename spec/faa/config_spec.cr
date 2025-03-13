require "../spec_helper"

describe Faa::Configuration do
  around_each do |test|
    original_config = Faa::Configuration::File::CONFIG_PATH
    test.run
    FileUtils.rm_rf(original_config) if File.exists?(original_config)
  end

  describe ".init" do
    it "initializes with default values when no config exists" do
      io = IO::Memory.new
      display = Faa::Display.new(io)
      
      config = Faa::Configuration.init(Faa::Configuration::File.new, display)
      config.active_project_library_path.should eq(config.serialisable.default_active_path)
      io.to_s.should be_empty
    end

    it "loads valid configuration from existing file" do
      valid_config = {
        active_project_library: "/custom/active",
        working_project_directory: "/custom/work",
        log_file: "/custom/log.log"
      }.to_json
      File.write(Faa::Configuration::File::CONFIG_PATH, valid_config)

      io = IO::Memory.new
      display = Faa::Display.new(io)
      config = Faa::Configuration.init(Faa::Configuration::File.new, display)

      config.active_project_library_path.should eq(Path["/custom/active"])
      config.working_project_directory_path.should eq(Path["/custom/work"])
      config.log_file_path.should eq(Path["/custom/log.log"])
      io.to_s.should be_empty
    end

    it "handles invalid JSON with error display and user fallback" do
      File.write(Faa::Configuration::File::CONFIG_PATH, "{invalid}")

      io = IO::Memory.new
      display = Faa::Display.new(io)
      
      # Simulate user pressing enter to accept defaults
      stdin = IO::Memory.new("\n")
      config = Faa::Configuration.init(Faa::Configuration::File.new, display)

      # Verify error display
      io.to_s.should contain("Invalid Config!")
      io.to_s.should contain("JSON::ParseException")
      io.to_s.should contain("Press enter if you want to proceed with a default config")
      
      # Verify fallback to default config
      config.active_project_library_path.should eq(config.serialisable.default_active_path)
    end

    it "handles empty config file as defaults" do
      File.touch(Faa::Configuration::File::CONFIG_PATH)
      
      io = IO::Memory.new
      display = Faa::Display.new(io)
      config = Faa::Configuration.init(Faa::Configuration::File.new, display)

      config.active_project_library_path.should eq(config.serialisable.default_active_path)
      io.to_s.should be_empty
    end
  end

  describe "#save!" do
    it "persists configuration changes to disk" do
      io = IO::Memory.new
      display = Faa::Display.new(io)
      config = Faa::Configuration.init(Faa::Configuration::File.new, display)
      
      new_active = Path["/new/active/path"]
      new_work = Path["/new/work/path"]
      
      config.overwrite!(new_active.to_s, new_work.to_s)
      config.save!

      # Verify file contents
      saved_content = File.read(Faa::Configuration::File::CONFIG_PATH)
      saved_config = Faa::Configuration::Serialisable.from_json(saved_content)
      saved_config.active_project_library_path.should eq(new_active)
      saved_config.working_project_directory_path.should eq(new_work)
    end
  end

  describe "Serialisable" do
    it "provides expected default paths" do
      serialisable = Faa::Configuration::Serialisable.new
      
      serialisable.default_active_path.to_s.should contain("Active Project Library")
      serialisable.default_working_path.to_s.should contain("faa_workspace")
      serialisable.default_log_file_path.to_s.should contain("faa.log")
    end

    it "uses configured paths when available" do
      serialisable = Faa::Configuration::Serialisable.from_json({
        active_project_library: "/custom/active",
        working_project_directory: "/custom/work",
        log_file: "/custom/log.log"
      }.to_json)
      
      serialisable.active_project_library_path.should eq(Path["/custom/active"])
      serialisable.working_project_directory_path.should eq(Path["/custom/work"])
      serialisable.log_file_path.should eq(Path["/custom/log.log"])
    end
  end

  describe "error handling" do
    it "shows proper error for missing required fields" do
      invalid_config = { log_file: "/custom.log" }.to_json
      File.write(Faa::Configuration::File::CONFIG_PATH, invalid_config)

      io = IO::Memory.new
      display = Faa::Display.new(io)
      
      # Simulate user accepting defaults
      stdin = IO::Memory.new("\n")
      config = Faa::Configuration.init(Faa::Configuration::File.new, display)

      io.to_s.should contain("JSON::SerializableError")
      io.to_s.should contain("Missing JSON attribute: active_project_library")
    end
  end
end
