require "log"
require "./log_formatter"

module Faa
  module Logging
    def self.setup_logging(config : Faa::Config)
      log_level = ::Log::Severity::Info
      log_path = config.log_file_path
      log_to_stderr = true

      # Ensure log directory exists
      FileUtils.mkdir_p(log_path.dirname)
      
      broadcast_backend = ::Log::BroadcastBackend.new
      
      # File backend
      file_backend = ::Log::IOBackend.new(
        io: File.open(log_path, "a"),
        formatter: StdoutLogFormat,
        dispatcher: ::Log::DirectDispatcher
      )
      broadcast_backend.append(file_backend, log_level)

      # STDERR backend
      if log_to_stderr
        stderr_backend = ::Log::IOBackend.new(
          io: STDERR,
          formatter: StdoutLogFormat,
          dispatcher: ::Log::DirectDispatcher
        )
        broadcast_backend.append(stderr_backend, log_level)
      end

      ::Log.setup(log_level, broadcast_backend)
      ::Log.info &.emit("Logging initialized", path: log_path.to_s)
    end
  end
end
