require "spec"
require "../src/faa/project_dir"

def with_temp_dir(path : String? = nil, &)
  path = File.join(Dir.tempdir, "#{path}#{Random.rand(0x100000000).to_s(36)}")
  Dir.mkdir_p(path, 0o0700)
  yield path
  FileUtils.rm_rf(path)
end
