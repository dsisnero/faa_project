require "spec"
require "../src/faa/config"
require "../src/faa/prompt"
require "./support/mock_prompt"

def with_temp_dir(path : String? = nil, &)
  path = File.join(Dir.tempdir, "#{path}#{Random.rand(0x100000000).to_s(36)}")
  Dir.mkdir_p(path, 0o0700)
  yield path
  FileUtils.rm_rf(path)
end

def with_temp_env(key, value, &)
  original = ENV[key]?
  ENV[key] = value
  yield
ensure
  ENV[key] = original
end

# Mock the Faa::Config.load to use test directory
def with_test_config
  original_config = Faa::Config.load
  test_config = Faa::Config.new
  test_config.working_project_directory = Dir.tempdir
  test_config.active_project_library = Dir.tempdir
  
  yield test_config
ensure
  original_config.try(&.save)
end


require "./faa/dir_spec"
require "./faa/utils_spec"
require "./faa/config_spec"
require "./faa/create_spec"
