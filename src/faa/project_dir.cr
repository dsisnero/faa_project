require "./project_dir"
require "baked_file_system"

class FileStorage
  Logger = Log.for(self)
  extend BakedFileSystem

  @@baked_files : Array(BakedFileSystem::BakedFile) = begin
    [] of BakedFileSystem::BakedFile
  end
    

  class_getter(baked_files) { BakedFileSystemMounter::BakedFileSystemStorage.baked_files }

  bake_folder "../../project_lib"

  def self.copy_to(dir : String | Path)
    base = Path.new(dir)
    raise "Not a dir" unless File.directory? base
    baked_files.each do |file|
        path = base / file.path
        dir = path.parent
        unless File.directory? dir
          Logger.debug {"making dir #{dir}"}
          FileUtils.mkdir_p(dir)
        end
        File.write(full_path, file.gets_to_end)
    end
  end
end



module Faa

  class ProjectDir
    BakedFileSystemMounter.assemble({
      "project_lib" => "../../project_lib"
    })

    getter dir : Path

    def initialize(@dir)
    end

    def empty?
      ::Dir.empty? dir
    end

    def make_subdirectories
      return unless empty?
      FileStorage.copy_to(dir)
    end

  end

end
