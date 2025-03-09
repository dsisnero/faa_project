require "../spec_helper"

describe Faa::Dir do
  around_each do |test|
    # Preserve original config state
    original_config = Faa::Config.load
    test.run
    original_config.save
  end

  describe "#initialize" do
    it "uses config defaults when no arguments given" do
      dir = Faa::Dir.new
      expected_active = Faa::Config.load.active_project_library_path
      dir.active_project_lib.should eq(expected_active)
    end

    it "allows custom path overrides" do
      custom_dir = Faa::Dir.new(
        active_project_lib: "/test/active",
        working_dir: "/test/work"
      )
      custom_dir.active_project_lib.should eq(Path["/test/active"])
    end
  end

  describe "#find_or_create_project_dir" do
    it "finds existing project directory" do
      with_temp_dir do |tmp|
        # Create test structure
        state_dir = File.join(tmp, "UT")
        jcn_dir = File.join(state_dir, "UT-25007236")
        Dir.mkdir_p(jcn_dir)

        # Test lookup
        dir = Faa::Dir.new(active_project_lib: tmp)
        result = dir.find_or_create_project_dir(state: "UT", jcn: "25007236")
        result.path.to_s.should contain("UT-25007236")
      end
    end

    it "creates new directory with LID when missing" do
      with_temp_dir do |tmp|
        dir = Faa::Dir.new(active_project_lib: tmp)
        result = dir.find_or_create_project_dir(
          state: "UT", 
          jcn: "25007236",
          city: "Ogden",
          locid: "OGD"
        )

        expected_path = File.join(tmp, "UT", "OGD (Ogden)")
        Dir.exists?(expected_path).should be_true
        result.path.should eq(Path.new(expected_path))
      end
    end
  end
end
