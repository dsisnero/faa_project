require "../spec_helper"

describe Faa::CLI do
  describe "config" do
    describe "show" do
      it "displays current configuration values" do
        output = IO::Memory.new
        Process.run("bin/faa", ["config", "show"], output: output, error: STDERR)

        expected = <<-CONFIG
        Active Project Library: #{Faa::Config.load.active_project_library_path}
        Working Directory: #{Faa::Config.load.working_project_directory_path}
        CONFIG

        output.to_s.strip.should contain(expected.strip.gsub(/\s+/, " "))
      end
    end

    describe "edit" do
      it "opens config file in editor" do
        with_temp_env("EDITOR", "echo") do
          output = IO::Memory.new
          Process.run("bin/faa", ["config", "edit"], output: output, error: STDERR)

          config_path = File.join(Faa::Config.dir, "config.yml")
          output.to_s.should contain(config_path)
        end
      end
    end
  end

  describe "unzip" do
    it "extracts valid zip files" do
      with_temp_dir do |tmp|
        zip_path = File.join(tmp, "test.zip")
        out_dir = File.join(tmp, "output")

        Compress::Zip::Writer.open(zip_path) do |zip|
          zip.add("test.txt", "content")
        end

        Process.run("bin/faa", ["unzip", zip_path, out_dir], output: STDOUT, error: STDERR)

        File.read(File.join(out_dir, "test.txt")).should eq("content")
      end
    end

    it "shows error for invalid zip files" do
      with_temp_dir do |tmp|
        invalid_zip = File.join(tmp, "bad.zip")
        File.write(invalid_zip, "corrupt data")

        output = IO::Memory.new
        error = IO::Memory.new
        status = Process.run("bin/faa", ["unzip", invalid_zip, tmp], output: output, error: error)

        status.success?.should be_false
        error.to_s.should contain("Failed to unzip")
      end
    end
  end
end
