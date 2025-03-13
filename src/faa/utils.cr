require "compress/zip"

module Faa
  module Utils
    extend self

    def edit_file(path : String | Path) : Nil
      path = path.to_s
      editor = ENV["EDITOR"]? || default_editor

      # Check if editor exists in PATH
      unless Process.find_executable(editor)
        raise "Editor '#{editor}' not found in PATH"
      end

      Process.run(
        command: editor,
        args: [path],
        input: STDIN,
        output: STDOUT,
        error: STDERR
      )
    end

    private def default_editor : String
      # Detect Windows
      if ENV.has_key?("ComSpec") || ENV.has_key?("PATHEXT")
        "notepad.exe"
      else
        # Try common editors in preferred order
        ["nano", "micro", "vim", "vi"].each do |editor|
          if exe = Process.find_executable(editor)
            return exe
          end
        end
        "vi" # Fallback if none found
      end
    end

    def unzip(zipfile : String | Path, outdir : String | Path) : Nil
      zip_path = zipfile.to_s
      output_dir = outdir.to_s

      ::Dir.mkdir_p(output_dir)

      Compress::Zip::Reader.open(zip_path) do |zip|
        zip.each_entry do |entry|
          target_path = File.join(output_dir, entry.filename)

          if entry.dir?
            ::Dir.mkdir_p(target_path)
          else
            ::Dir.mkdir_p(File.dirname(target_path))
            File.write(target_path, entry.io)
          end
        end
      end
    rescue ex : Compress::Zip::Error | File::NotFoundError
      raise "Failed to unzip #{zip_path}: #{ex.message}"
    rescue ex
      raise "Failed to unzip #{zip_path}: #{ex.message}"
    end
  end
end
