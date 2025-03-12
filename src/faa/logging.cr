require "log"
require "./log_formatter"

module Faa
  module Logging

    def self.setup_logging(
      log_level : Symbol = :info,
      file_path : Path? = nil,
      log_to_stderr : Bool = true,
    )
      log_level = ::Log::Severity.parse(log_level.to_s)
      broadcast_backend = ::Log::BroadcastBackend.new
      # Create log backend for file if path is provided

      if file_path
        dirname = file_path.dirname
        FileUtils.mkdir_p(dirname)
        log_file = File.open(file_path, "a")
      else
        log_file = STDOUT
      end

      file_backend = ::Log::IOBackend.new(io: log_file, formatter: StdoutLogFormat, dispatcher: ::Log::DirectDispatcher)

      broadcast_backend.append(file_backend, log_level)

      # in_memory_backend = ::Log::InMemoryBackend.instance
      # broadcast_backend.append(in_memory_backend, log_level)
      ::Log.setup(log_level, broadcast_backend)
      target = (path = file_path) ? path.to_s : "stdout"
      Log.info &.emit("Logger settings", level: log_level.to_s, target: target)
    end
  end
end
