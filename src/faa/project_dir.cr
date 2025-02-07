require "./project_dir"
require "baked_file_system"
require "baked_file_system_mounter"
require "log"

Log.setup_from_env
module Faa
  class FileStorage
    extend BakedFileSystem

    folder = File.join(__DIR__, "../project_lib")

    bake_folder "../../project_lib"

    class_getter baked_files : Array(String) = begin
     path = File.join(__DIR__,"../../project_lib")
     ::Dir.glob("#{path}/**/*").select { |file| File.file? file }.map{|f| f.sub(path,"")}
    end
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
      FileStorage.baked_files.each do |fname|
        path = base / fname
        dir = path.parent
        Logger.debug { "dir #[dir} : path #{path}]"}
        unless File.directory? dir
          Logger.debug { "making dir #{dir}" }
          FileUtils.mkdir_p(dir)
        end
        contents = FileStorage.get(fname).gets_to_end
        File.write(path, contents)
      end
    end
  end
end
