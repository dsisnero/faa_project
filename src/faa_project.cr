module Faa
  ROOT = Path.new(__DIR__).parent

  PROJECT_LIB = ROOT / "project_lib"
end

require "./faa/dir"
require "./faa/utils"
require "./faa/cli"

Faa::CLI.run(ARGV)
