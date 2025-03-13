require "./spec_helper"
require "../src/faa_project"

describe Faa do
  describe "core functionality" do
    it "initializes directory structure correctly" do
      with_temp_dir do |tmp|
        config = Faa::Config.new.tap do |c|
          c.active_project_library = tmp
          c.working_project_directory = tmp
        end
        
        dir = Faa::Dir.new(config: config)
        result = dir.find_or_create_project_dir(
          state: "Utah",
          jcn: "TEST123",
          city: "TestCity",
          locid: "TLOC",
          factype: "TestFacility",
          title: ""
        )

        expected_path = File.join(tmp, "Utah", "TLOC (Testcity)", "TLOC TESTFACILITY - TEST123")
        Dir.exists?(expected_path).should be_true
      end
    end
  end
end
