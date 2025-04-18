# require "file_utils"
# require "log"
# require "./logging"
# require "./fast_find"
# require "./project_dir"
# require "./config"

# TODO: Write documentation for `FaaProject`
module Faa
  VERSION = "0.1.0"

  # dir = Faa::Dir.new
  # proj_dir = dir.find_or_create_project_dir(state: "Utah", jcn: "25007236")
  class Dir
    Logger = Log.for(self)
    # property state : String

    # property lid : String

    # property jcn : String

    getter active_project_lib : ::Path

    getter working_dir : ::Path

    getter fast_find_config : FastFind::Config

    protected def error(msg : ::String) : Nil
      STDERR << "» Error: " << msg << '\n'
    end

    def initialize(
      active_project_lib : Path | String,
      working_dir : Path | String,
      @fast_find_config : FastFind::Config = FastFind::Config.new,
    )
      @active_project_lib = Path.new active_project_lib
      @working_dir = Path.new working_dir
    end

    def directory_from_state_abbrv(abbrev : String)
    end

    # # return the first entry where the block parameter returns tru
    # # uses FastFind.find and the active_project_lib path
    # def find_dir_or_file(not_found = nil, depth : Int32? = nil, &block : FastFind::Entry -> Bool)
    #   config = fast_find_config.dup
    #   config.max_depth = depth if depth

    #   result = nil

    #   begin
    #     FastFind.find(active_project_lib.to_s, config) do |entry|
    #       match = yield(entry)
    #       if match == true
    #         result = entry
    #         break
    #       end
    #     end
    #   rescue ex
    #     Log.error{ "Error in #{entry}\n***\n #{ex.message}"}
    #     not_found
    #   end
    #   result || not_found
    # end

    def find_or_create_project_dir(state : ::String, jcn : ::String, city : ::String, locid : ::String, factype : ::String, title : ::String?)
      # Add validation checks
      missing = [] of ::String
      missing << "city" if city.blank?
      missing << "locid" if locid.blank?
      missing << "factype" if factype.blank?

      unless missing.empty?
        error "Missing required parameters: #{missing.join(", ")}"
        exit 1
      end

      state_path = active_project_lib / state.capitalize
      path = find_dir_or_file(base: state_path) do |entry|
        entry.path.to_s.downcase.includes?(jcn.downcase)
      end

      if path
        ProjectDir.new(path.path)
      else
        create_project_dir(state_path, city, locid, jcn, factype, title)
      end
    end

    def city_locid_dirname(city : ::String, locid : ::String)
      "#{locid.upcase} (#{city.capitalize})"
    end

    def project_dir_name(locid, factype, jcn, title : ::String? = nil)
      ::String.build do |s|
        s << "#{locid.upcase} #{factype.upcase}"
        if title && !title.empty?
          s << " - #{title.upcase}"
        end
        s << " - #{jcn.upcase}"
      end
    end

    def create_project_dir(state_path : ::Path, city : ::String, locid : ::String, jcn : ::String, factype : ::String, title : ::String? = nil)
      locid_city_path = state_path / city_locid_dirname(city, locid)
      project_path = locid_city_path / project_dir_name(locid, factype, jcn, title)

      ::Dir.mkdir_p(project_path)
      ProjectDir.new(project_path)
    end

    def lid_dir_name(lid : ::String, city : ::String)
      "#{lid.upcase} (#{city})"
    end

    private def find_dir_or_file(base = active_project_lib, not_found = nil, depth : Int32? = nil, & : FastFind::Entry -> Bool)
      # Configure depth if provided
      config = fast_find_config.dup
      config.max_depth = depth if depth

      # Store the first matching entry
      result = nil

      begin
        # Log the start of the search
        Logger.debug { %[Searching in #{base} with max depth: #{depth || "unlimited"}"] }

        FastFind.find(base.to_s, config) do |entry|
          # Log each entry being processed
          Logger.debug { "Processing entry: #{entry.path}" }

          # Explicitly convert to boolean
          match = begin
            yield_result = yield(entry)

            !!yield_result
          rescue ex
            Logger.error(exception: ex) { "Error in matching block for entry #{entry.path}" }
            false
          end

          if match
            Logger.debug { "Found matching entry: #{entry.path}" }
            result = entry
            break # Stop searching once first match is found
          end
        end
      rescue ex
        Logger.error(exception: ex) { "Error in find_dir_or_file" }
      end

      # Log the final result
      if result.nil?
        Logger.warn { "No matching entry found" }
      end

      # Return the result or the not_found value
      result || not_found
    end
  end
end
