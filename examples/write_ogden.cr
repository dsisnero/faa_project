require "../src/faa/project_dir"
require "../src/faa/utils"
require "../src/faa/dir"

require "file_utils"

dir = File.join(__DIR__, "ogd_rtr")

FileUtils.mkdir_p dir

# Default config-based usage
default_dir = Faa::Dir.new
puts "Using active library: #{default_dir.active_project_lib}"

# Custom path override
custom_dir = Faa::Dir.new(
  active_project_lib: "/custom/active",
  working_dir: "/custom/workspace"
)
puts "Using custom active library: #{custom_dir.active_project_lib}"

proj_dir = Faa::ProjectDir.new(dir)

proj_dir.make_subdirectories

Faa::Utils.unzip("sample_project.zip", dir)
