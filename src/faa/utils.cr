require "compress/zip"

module Faa::Utils
  extend self

  def unzip(zipfile : String | Path, outdir : String | Path) : Nil
    zip_path = zipfile.to_s
    output_dir = outdir.to_s

    Dir.mkdir_p(output_dir)

    Compress::Zip::Reader.open(zip_path) do |zip|
      zip.each_entry do |entry|
        target_path = File.join(output_dir, entry.filename)
        
        if entry.dir?
          Dir.mkdir_p(target_path)
        else
          Dir.mkdir_p(File.dirname(target_path))
          File.write(target_path, entry.io)
        end
      end
    end
  rescue ex
    raise Error.new("Failed to unzip #{zip_path}: #{ex.message}")
  end
end
