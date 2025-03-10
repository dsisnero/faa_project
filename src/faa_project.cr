module Faa
  ROOT = Path.new(__DIR__).parent

  PROJECT_LIB = ROOT / "project_lib"
end

require "./faa/dir"
require "./faa/utils"
require "./faa/app"
begin
  Faa::App.new.execute(ARGV)
rescue
  exit 1
end
