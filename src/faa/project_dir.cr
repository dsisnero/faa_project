require "./project_dir"
require "baked_file_system"
require "log"

Log.setup_from_env

module Faa
  class FileStorage
    extend BakedFileSystem

    bake_folder "../../project_lib"
  end

  class ProjectDir
    Logger = Log.for(self)

    getter dir : Path

    def initialize(dir : Path | String)
      @dir = Path.new(dir)
    end

    def empty?
      ::Dir.empty? dir
    end

    # make project directories and files using the project_lib files
    # make them a subdirectory of dir
    def make_subdirectories
      return unless empty?
      base = Path.new(dir)
      # files_in_storage = FileStorage.files.map(&.path)
      # pp! files_in_storage
      FileStorage.files.each do |file|
        path = base / file.path
        dir = path.parent
        Logger.debug { "dir #[dir} : path #{path}]" }
        FileUtils.mkdir_p(dir) unless File.directory? dir
        File.write(path, file.gets_to_end) unless File.exists? path
      end
    end
  end
end
