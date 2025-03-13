require "../spec_helper"

describe Faa::Config do
  around_each do |test|
    original_dir = Faa::Config.dir
    test.run
    Faa::Config.dir = original_dir
  end

  describe ".load" do
    it "creates new config with defaults when missing" do
      with_temp_dir do |tmp|
        Faa::Config.dir = tmp

        config = Faa::Config.load
        config.active_project_library_path.should eq(config.default_active_path)
        config.working_project_directory_path.should eq(config.default_working_path)
      end
    end

    it "loads existing config values" do
      with_temp_dir do |tmp|
        Faa::Config.dir = tmp
        File.write(File.join(tmp, "config.yml"), <<-YAML
          active_project_library: /custom/active
          working_project_directory: /custom/work
        YAML
        )

        config = Faa::Config.load
        config.active_project_library_path.should eq(Path["/custom/active"])
        config.working_project_directory_path.should eq(Path["/custom/work"])
      end
    end

    it "regenerates config on invalid YAML" do
      with_temp_dir do |tmp|
        Faa::Config.dir = tmp
        File.write(File.join(tmp, "config.yml"), "invalid: yaml: here")

        config = Faa::Config.load
        config.active_project_library_path.should eq(config.default_active_path)
      end
    end

    describe "#log_file_path" do
      it "returns default log path when not configured" do
        config = Faa::Config.new
        config.log_file = nil

        config.log_file_path.should eq(config.default_log_file_path)
      end

      it "returns custom log path when configured" do
        config = Faa::Config.new
        config.log_file = "/custom/path/to/log.txt"

        config.log_file_path.should eq(Path["/custom/path/to/log.txt"])
      end
    end
  end
end
