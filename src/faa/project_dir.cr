require "./project_dir"
require "baked_file_system"
require "baked_file_system_mounter"

module Faa
  class ProjectDir
    BakedFileSystemMounter.assemble({
      "project_lib" => "../../project_lib"
    })

    @@baked_files : Array(BakedFileSystem::BakedFile)? = nil

    class_getter(baked_files) do
      @@baked_files ||= BakedFileSystemMounter::BakedFileSystemStorage.baked_files
    end

    getter dir : Path

    def initialize(@dir)
    end

    def empty?
      ::Dir.empty? dir
    end

    # make project directories and files using the project_lib files
    # make them a subdirectory of dir
    def make_subdirectories
      return unless empty?
      
      self.class.baked_files.each do |file|
        target_path = dir / file.path
        FileUtils.mkdir_p(target_path.dirname)
        File.write(target_path, file_contents(file))
      end
    end

    private def file_contents(file)
      String.new(file.io.to_slice)
    end
  end
end
