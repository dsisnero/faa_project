require "../spec_helper"
require "../../src/faa/dir"
  def project_args(**overrides)
    {
      state: "UT",
      jcn: "25007236",
      city: "TestCity",
      locid: "LOC123",
      factype: "TestFacility",
      title: ""
    }.merge(overrides)
  end

describe Faa::Dir do
  around_each do |test|
    # Preserve original config state
    original_config = Faa::Config.load
    test.run
    original_config.save
  end


  describe "#initialize" do
    it "uses config defaults when no arguments given" do
      with_test_config do |config|
        dir = Faa::Dir.new(config: config)
        dir.active_project_lib.should eq(config.active_project_library_path)
      end
    end

    it "allows custom path overrides" do
      with_test_config do |config|
        custom_dir = Faa::Dir.new(
          config: config,
          active_project_lib: "/test/active",
          working_dir: "/test/work"
        )
        custom_dir.active_project_lib.should eq(Path["/test/active"])
      end
    end
  end

  describe "#find_or_create_project_dir" do
    it "finds existing project directory" do
      with_temp_dir do |tmp|
        # Create test structure using the same args as our helper
        state_dir = File.join(tmp, "UT")
        project_dir = File.join(state_dir, "LOC123 (TestCity)")  # Matches default args
        Dir.mkdir_p(project_dir)

        # Test lookup with full arguments
        dir = Faa::Dir.new(active_project_lib: tmp)
        result = dir.find_or_create_project_dir(**project_args)
        result.path.to_s.should contain("LOC123 (TestCity)")
      end
    end

    it "creates new directory with LID when missing" do
      with_temp_dir do |tmp|
        dir = Faa::Dir.new(active_project_lib: tmp)
        result = dir.find_or_create_project_dir(
          **project_args(
            city: "Ogden",
            locid: "OGD",
            factype: "Airport" # Adding missing required argument
          )
        )

        expected_path = File.join(tmp, "UT", "OGD (Ogden)")
        Dir.exists?(expected_path).should be_true
        result.path.should eq(Path.new(expected_path))
      end
    end

    it "validates required arguments" do
      with_temp_dir do |tmp|
        dir = Faa::Dir.new(active_project_lib: tmp)
        
        # Test empty city
        expect_raises(Exception, /City.*required/) do
          dir.find_or_create_project_dir(**project_args.merge(city: ""))
        end
        
        # Test empty locid
        expect_raises(Exception, /Locid.*required/) do
          dir.find_or_create_project_dir(**project_args.merge(locid: ""))
        end

        # Test empty factype
        expect_raises(Exception, /Factype.*required/) do
          dir.find_or_create_project_dir(**project_args.merge(factype: ""))
        end
      end
    end
  end
end
