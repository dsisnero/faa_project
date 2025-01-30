# spec/faa/project_dir_spec.cr
require "spec"
require "file_utils"
require "../../src/faa/project_dir"

describe Faa::ProjectDir do
  # Temporary directory for testing
  temp_dir = Path["/tmp/faa_project_dir_spec_#{Random.rand(10000)}"]

  around_each do |test|
    # Create temporary directory before each test
    FileUtils.mkdir_p(temp_dir)

    begin
      test.run
    ensure
      # Clean up temporary directory after each test
      FileUtils.rm_rf(temp_dir)
    end
  end

  describe "#make_subdirectories" do
    it "creates subdirectories and files from baked filesystem" do
      project_dir = Faa::ProjectDir.new(temp_dir)

      # Verify initial state is empty
      project_dir.empty?.should be_true

      # Call method to create subdirectories
      project_dir.make_subdirectories

      # Check that files and directories were created
      expected_entries = [
        "src",
        "src/main.cr",
        "README.md",
        "shard.yml"
      ]

      expected_entries.each do |entry_path|
        full_path = temp_dir / entry_path
        File.exists?(full_path).should be_true, "Expected #{full_path} to exist"
      end
    end

    it "does not create subdirectories if directory is not empty" do
      # Create a file in the temp directory to make it non-empty
      File.write(temp_dir / "existing_file.txt", "Some content")

      project_dir = Faa::ProjectDir.new(temp_dir)

      # Verify initial state is not empty
      project_dir.empty?.should be_false

      # Call method
      project_dir.make_subdirectories

      # Verify no additional files were created
      Dir.entries(temp_dir).should contain("existing_file.txt")
      Dir.entries(temp_dir).size.should eq(3)  # ".", "..", and "existing_file.txt"
    end

    it "preserves file contents from baked filesystem" do
      project_dir = Faa::ProjectDir.new(temp_dir)
      project_dir.make_subdirectories

      # Check contents of a specific file
      main_cr_path = temp_dir / "src" / "main.cr"
      File.exists?(main_cr_path).should be_true

      # Assuming the baked main.cr contains some specific content
      File.read(main_cr_path).should contain("def main")
    end
  end
end
