require "baked_file_system_mounter"

BakedFileSystemMounter.assemble(
  {"project_lib" => "#{Faa::PROJECT_LIB}"}
)

module Faa
  class ProjectDir
    getter dir : Path

    def initialize(@dir)
    end

    def empty?
      Dir.empty? dir
    end

    def make_subdirectories
      return unless empty?
      # Iterate through all entries in the baked filesystem
      BakedFileSystemMounter.mounts["project_lib"].entries.each do |entry|
        # Construct the full path by joining the project directory with the entry path
        full_path = dir / entry.path

        if entry.dir?
          # If it's a directory, create the directory
          FileUtils.mkdir_p(full_path)
        else
          # If it's a file, create the parent directory and write the file contents
          FileUtils.mkdir_p(File.dirname(full_path))

          # Write the file contents
          File.write(full_path, entry.read)
        end
      end
    end
  end
end
