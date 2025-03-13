require "spec"
require "../src/faa_project"
require "./support/configuration/fixture_file"

module Configuration
  class TestConfig < Faa::Configuration::AbstractFile
    def initialize(@content : String? = nil)
    end

    def read : ::String?
      @content
    end

    def write(content : ::String)
      @content = content
    end

    def close
      # no-op
    end
  end
end

def with_config(config, &)
  with_config_file(config) do |_|
    display = Faa::Display.new(IO::Memory.new)
    config = Faa::Configuration.init(test_file, display)
    yield config
  end
end

def with_config_file(config : Hash, &)
  test_file = Configuration::TestConfig.new(config.to_json)
  yield test_file
end

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
