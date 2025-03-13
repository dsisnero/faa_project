require "spec"
require "../src/faa/config"
require "../src/faa/prompt"
require "../src/faa/utils"
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
def with_test_config(&)
  original_config = Faa::Config.load
  test_config = Faa::Config.new
  test_config.working_project_directory = Dir.tempdir
  test_config.active_project_library = Dir.tempdir

  yield test_config
ensure
  original_config.try(&.save)
end

def capture_stderr(&)
  # Create a pipe for capturing output
  reader, writer = IO.pipe
  original_stderr = STDERR.dup

  # Redirect stderr to our pipe writer
  STDERR.reopen(writer)
  yield

  # Close writer and read output
  writer.close
  reader.gets_to_end
ensure
  # Restore original stderr
  STDERR.reopen(original_stderr.not_nil!)
  reader.try(&.close)
  writer.try(&.close)
end

def capture_exit_code(&)
  exit_code = 0
  begin
    yield
  rescue ex : ::Exception
    exit_code = ex.message
  end
  exit_code
end

require "./faa/dir_spec"
require "./faa/utils_spec"
require "./faa/config_spec"
require "./faa/create_spec"
