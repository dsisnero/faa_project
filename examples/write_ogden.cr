require "../src/faa/project_dir"
require "../src/faa/utils"

require "file_utils"

dir = File.join(__DIR__, "ogd_rtr")

FileUtils.mkdir_p dir

proj_dir = Faa::ProjectDir.new(dir)

proj_dir.make_subdirectories

Faa::Utils.unzip("sample_project.zip", dir)
