require "../spec_helper"

describe Faa::Utils do
  describe ".unzip" do
    it "extracts zip contents recursively" do
      with_temp_dir do |tmp|
        zip_path = File.join(tmp, "test.zip")
        output_dir = File.join(tmp, "output")

        # Create test zip
        Compress::Zip::Writer.open(zip_path) do |zip|
          zip.add("test.txt", "content")
          zip.add("nested/file.txt", "nested")
        end

        Faa::Utils.unzip(zip_path, output_dir)
        
        # Verify extraction
        File.read(File.join(output_dir, "test.txt")).should eq("content")
        File.read(File.join(output_dir, "nested/file.txt")).should eq("nested")
      end
    end

    it "raises error on invalid zip files" do
      with_temp_dir do |tmp|
        invalid_zip = File.join(tmp, "corrupt.zip")
        File.write(invalid_zip, "invalid data")

        expect_raises(Faa::Error, /Failed to unzip/) do
          Faa::Utils.unzip(invalid_zip, tmp)
        end
      end
    end
  end
end
