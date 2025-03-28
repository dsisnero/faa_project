require "json"
require "./faa/**"

module Faa
  extend self

  def main(args : Array(::String), stdin : IO, stdout : IO, config_file : Configuration::AbstractFile) : Context
    build_context(stdin, stdout, config_file).tap do |context|
      Commands::Main.new(context).execute(args)
    end
  ensure
    config_file.close
  end

  def exit!(status = 0) : NoReturn
    ::exit status
  end

  private def build_context(stdin : IO, stdout : IO, config_file : Configuration::AbstractFile) : Context
    display = Display.new(stdout)
    input = Input.new(stdin, display)
    config = Configuration.init(config_file, display)
    faa_dir = faa_dir_from_config(config)

    Context.new(
      stdout,
      config,
      display,
      input,
      faa_dir
    )
  end

  private def faa_dir_from_config(config : Configuration) : Dir?
    Dir.new(config.active_project_library_path, config.working_project_dir_path)
  end
end

{% unless flag?(:test) %}
  {% if flag?(:debug) %}
    #Faa::Debug.setup
  {% end %}

  Faa.main(
    args: ARGV,
    stdout: STDOUT,
    stdin: STDIN,
    config_file: Faa::Configuration::File.new
  )
{% end %}
module Faa
  def self.exit(code = 0)
    ::exit(code)
  end
end
