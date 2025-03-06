require "./spec_helper"
require "xdg"

describe XDG do
  describe ".config_home" do
    it "returns default path when XDG_CONFIG_HOME not set" do
      ENV.delete("XDG_CONFIG_HOME")
      expected = {% if flag?(:win32) %}
        File.join(ENV["APPDATA"], "config")
      {% else %}
        File.join(Dir.home, ".config")
      {% end %}
      XDG.config_home.should eq expected
    end
  end

  # Similar specs for data_home, cache_home, and runtime_dir
end

describe Faa::Config do
  it "saves config to XDG location" do
    config = Faa::Config.load
    config_path = File.join(XDG.config_home, "faa_project", "config.yml")
    
    File.exists?(config_path).should be_true
    File.read(config_path).should contain("active_project_library")
  end
end
