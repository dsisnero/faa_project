require "./project_dir"
require "baked_file_system"
require "baked_file_system_mounter"



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

    # make project directories and files using the project_lib files
    # make them a subdirectory of dir
    def make_subdirectories
      return unless empty?
    end

  end

end
