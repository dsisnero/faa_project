require "file_utils"
require "wait_group"
require "log"

module FastFind
  Log.setup_from_env

  Logger = ::Log.for(self)

  # Configuration for traversal
  class Config
    Logger = ::Log.for(self)
    # Configurable options for directory traversal
    property max_depth : Int32 = Int32::MAX
    property follow_symlinks : Bool = false
    property ignore_hidden : Bool = true
    property error_handler : Proc(Exception, Bool)? = nil

    def initialize
      @error_handler = ->(ex : Exception) do
        Logger.error { "Error in traversal: #{ex.message}" }
        false
      end
    end
  end

  # Represents a file/directory entry with metadata
  struct Entry
    getter path : Path
    getter metadata : File::Info?
    getter type : Symbol # :file, :directory, :symlink

    def initialize(@path : Path, @metadata : File::Info?, @type : Symbol)
    end

    def readable?
      return false unless metadata
      metadata.not_nil!.readable?
    end

    def file?
      @type == :file
    end

    def directory?
      @type == :directory
    end

    def symlink?
      @type == :symlink
    end
  end

  # High-performance directory walker
  class Walker
    Logger = Log.for(self)
    # Use a concurrent queue for efficient directory processing
    @queue : Channel(Entry)
    @config : Config
    @wait_group = WaitGroup.new

    def initialize(
      @paths : Array(String),
      @config : Config = Config.new,
    )
      @queue = Channel(Entry).new(capacity: 1024)
      Logger.debug { "Walker initiated with paths: #{@paths}" }
    end

    # Parallel directory traversal using Crystal's lightweight concurrency
    def walk
      spawn do
        @paths.each do |root_path|
          spawn do
            @wait_group.add(1)
            begin
              Logger.debug { " Processing directory #{root_path}" }
              process_directory(Path.new(root_path), 0)
            rescue ex
              Logger.error { "Error processing directory #{root_path}\n#{ex.message}" }
            ensure
              @wait_group.done
              Logger.debug { "Finished processing directory: #{root_path}" }
            end
          rescue ex
            Logger.error { "in outer spawn\n#{ex.message}\n\n" }
            next
          end
        end

        spawn do
          Logger.debug { "Waiting for all directory processing to complete" }
          @wait_group.wait
          Logger.debug { "All directory processing is complete - closing queue" }
          @queue.close
        end
      end
      @queue
    end

    private def process_directory(path : Path, depth : Int32)
      Logger.debug { "Entering directory: #{path}, depth: #{depth}" }

      return if depth > @config.max_depth

      # Skip hidden directories if configured
      return if @config.ignore_hidden && path.basename.to_s.starts_with?('.')

      return unless File.directory? path

      return unless File::Info.readable? path

      begin
        Dir.each_child(path) do |child_name|
          child_path = path / child_name

          begin
            Log.debug { "Processing child: #{child_path}" }

            begin
              metadata = File.info?(child_path, follow_symlinks: @config.follow_symlinks)
            rescue ex
              Logger.warn { "Could not get metadata for #{child_path} #{ex.message}" }
            end

            # skip if metadata could not be retrieved
            next unless metadata

            entry_type = determine_entry_type(metadata)
            entry = Entry.new(child_path, metadata, entry_type)

            @queue.send(entry)

            # Recursively process directories
            if entry.directory? && File::Info.readable?(child_path)
              begin
                if File::Info.readable?(child_path)
                  process_directory(child_path, depth + 1)
                end
              rescue ex
                Logger.warn { "Could not process directory #{child_path}: #{ex.message}" }
                # Continue processing even if this directory fails
              end
            end
          rescue ex
            Logger.error { "Error processing child path #{child_path}: #{ex.message}" }
            # continue to next child if this one fails
            next
          end
        end
      rescue ex : IO::Error | File::Error
        # more specific error handling for directory reaading
        Logger.warn { "Could not read directory #{path}\n #{ex.message}\n\n" }
        # use error handler if configured
        handle_error(ex)
      rescue ex
        Logger.error { "Unexpected error processing directory #{path}: #{ex.message}" }
        handle_error(ex)
      end
    end

    private def determine_entry_type(metadata : File::Info?) : Symbol
      return :unknown unless metadata
      case
      when metadata.directory? then :directory
      when metadata.symlink?   then :symlink
      when metadata.file?      then :file
      else                          :unknown
      end
    end

    private def handle_error(ex : Exception)
      if handler = @config.error_handler
        continue = handler.call(ex)
        raise ex unless continue
      end
    end
  end

  # Main interface for directory traversal
  def self.find(
    path : String | Path,
    config : Config = Config.new,
    & : Entry ->
  )
    walker = Walker.new([path.to_s], config)
    queue = walker.walk
    loop do
      begin
        entry = queue.receive?
        break if entry.nil?
        Logger.debug { "Received entry #{entry}" }
        yield entry
      rescue Channel::ClosedError
        break
      end
    end
  end

  # Main interface for directory traversal
  def self.find(
    paths : Array(String),
    config : Config = Config.new,
    & : Entry ->
  )
    walker = Walker.new(paths, config)
    queue = walker.walk
    loop do
      begin
        entry = queue.receive?
        break if entry.nil?
        Logger.debug { "Received entry #{entry}" }
        yield entry
      rescue Channel::ClosedError
        break
      end
    end
  end
end
