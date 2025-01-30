module Faa
  ROOT = Path.new(__DIR__).parent

  PROJECT_LIB = ROOT / "project_lib"
end

require "./faa/dir"

dir = Faa::Dir.new
proj_dir = dir.find_or_create_project_dir(state: "Utah", jcn: "25007236")
pp! proj_dir

puts "Faa project lib is #{Faa::PROJECT_LIB}"
pp! Faa::PROJECT_LIB
