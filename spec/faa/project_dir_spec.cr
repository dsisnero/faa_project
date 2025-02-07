# spec/faa/project_dir_spec.cr
require "../spec_helper"
require "file_utils"
require "../../src/faa/project_dir"

def create_tests
  [
    "01 - Planning/Planning - Recommended Files v1.0.pdf",
    "02 - Engineering/Engineering - Recommended Files v1.0.pdf",
    "04 - ORM/ORM - Recommended Files v1.0.pdf",
    "05 - Construction/Construction - Recommended Files v1.0.pdf",
    "06 - Installation/Installation - Recommended Files v1.0.pdf",
    "07 - Closeout/Closeout - Recommended Files v1.0.pdf",
  ]
end

module Faa
  describe ProjectDir do
    describe "#make_subdirectories" do
      it "creates subdirectories and files from baked filesystem" do
        with_temp_dir do |test_dir|
          project_dir = ProjectDir.new(test_dir)
          project_dir.make_subdirectories

          testfiles = create_tests
          testfiles.each do |rel_path|
            full_path = File.join(test_dir, rel_path)
            pp! ::Dir.new(project_dir.dir).children if !File.exists?(full_path)
            File.exists?(full_path).should be_true,
              "Missing expected file: #{full_path}"
          end
        end
      end

      it "does not create subdirectories if directory is not empty" do
        with_temp_dir do |test_dir|
          File.write(File.join(test_dir, "existing.txt"), "test")
          project_dir = ProjectDir.new(test_dir)
          project_dir.make_subdirectories

          testfiles = create_tests
          testfiles.any? do |rel_path|
            File.exists? File.join(test_dir, rel_path)
          end.should be_false
        end
      end

      # copy the files from project_lib and make sure the content is the
      # same
      pending "preserves file contents from baked filesystem" do
      end
    end
  end
end
