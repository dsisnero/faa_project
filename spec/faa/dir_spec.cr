require "../spec_helper"
require "../../src/faa/dir"

def project_args(**overrides)
  {
    state:   "Utah", # always in correct format from create command
    jcn:     "25007236",
    city:    "TestCity",
    locid:   "LOC123",
    factype: "TestFacility",
    title:   "",
  }.merge(overrides)
end

describe Faa::Dir do
  describe "#initialize" do
        active_lib = "testlib"
        working_lib = "workinglib"
        
        dir = Faa::Dir.new(active_project_lib: active_lib,
                    working_dir: working_lib)
        dir.active_project_lib.to_s.should eq(active_lib)
        dir.working_dir.to_s.should eq(working_lib)
  end

  describe "#find_or_create_project_dir" do
    it "finds existing project directory" do
      with_temp_dir do |tmp|
        # Create test structure using the same args as our helper
        state_dir = File.join(tmp, "Utah")
        project_dir = File.join(state_dir, "LOC123 (Testcity)") # Matches default args
        Dir.mkdir_p(project_dir)

        # Test lookup with full arguments
        dir = Faa::Dir.new(
          active_project_lib: Path[tmp],
          working_dir: Path[tmp]
        )
        result = dir.find_or_create_project_dir(**project_args)
        result.path.to_s.should contain("LOC123 (Testcity)")
      end
    end

    it "creates new directory if directory doesnt exist" do
      with_temp_dir do |tmp|
        jcn = project_args[:jcn]
        expected_path = File.join(tmp, "Utah", "OGD (Ogden)", "OGD ATCT - #{jcn}")
        Dir.exists?(expected_path).should be_false
        dir = Faa::Dir.new(
          active_project_lib: Path[tmp],
          working_dir: Path[tmp]
        )
        result = dir.find_or_create_project_dir(
          **project_args(
            city: "Ogden",
            locid: "OGD",
            factype: "atct" # Adding missing required argument
          )
        )

        result.path.should eq(Path.new(expected_path))
        Dir.exists?(expected_path).should be_true
      end
    end
    it "creates new directory if directory doesnt exist and adds title if given" do
      with_temp_dir do |tmp|
        jcn = project_args[:jcn]
        expected_path = File.join(tmp, "Utah", "OGD (Ogden)", "OGD ATCT - RTIR SITE PREP - #{jcn}")
        Dir.exists?(expected_path).should be_false
        dir = Faa::Dir.new(
          active_project_lib: Path[tmp],
          working_dir: Path[tmp]
        )
        result = dir.find_or_create_project_dir(
          **project_args(
            city: "Ogden",
            locid: "OGD",
            factype: "atct",
            title: "rtir site prep" # Adding missing required argument
          )
        )

        result.path.should eq(Path.new(expected_path))
        Dir.exists?(expected_path).should be_true
      end
    end

    it "validates required arguments" do
      with_temp_dir do |tmp|
        dir = Faa::Dir.new(active_project_lib: tmp, working_dir: tmp)

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
