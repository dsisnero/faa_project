require "spec"
require "../src/faa_project"


 ROOT = Path.new(__DIR__).parent

TEMP_DIR = ROOT / "temp"

FileUtils.mkdir_p TEMP_DIR
