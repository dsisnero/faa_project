require "../config"

module Faa::Commands
  class Create < Base
    class_property prompt : Faa::Prompt = Faa::Prompt.new
    STATE_MAPPINGS = {
      "al" => "Alabama",
      "ak" => "Alaska",
      "az" => "Arizona",
      "ar" => "Arkansas",
      "ca" => "California",
      "co" => "Colorado",
      "ct" => "Connecticut",
      "de" => "Delaware",
      "fl" => "Florida",
      "ga" => "Georgia",
      "hi" => "Hawaii",
      "id" => "Idaho",
      "il" => "Illinois",
      "in" => "Indiana",
      "ia" => "Iowa",
      "ks" => "Kansas",
      "ky" => "Kentucky",
      "la" => "Louisiana",
      "me" => "Maine",
      "md" => "Maryland",
      "ma" => "Massachusetts",
      "mi" => "Michigan",
      "mn" => "Minnesota",
      "ms" => "Mississippi",
      "mo" => "Missouri",
      "mt" => "Montana",
      "ne" => "Nebraska",
      "nv" => "Nevada",
      "nh" => "New Hampshire",
      "nj" => "New Jersey",
      "nm" => "New Mexico",
      "ny" => "New York",
      "nc" => "North Carolina",
      "nd" => "North Dakota",
      "oh" => "Ohio",
      "ok" => "Oklahoma",
      "or" => "Oregon",
      "pa" => "Pennsylvania",
      "ri" => "Rhode Island",
      "sc" => "South Carolina",
      "sd" => "South Dakota",
      "tn" => "Tennessee",
      "tx" => "Texas",
      "ut" => "Utah",
      "vt" => "Vermont",
      "va" => "Virginia",
      "wa" => "Washington",
      "wv" => "West Virginia",
      "wi" => "Wisconsin",
      "wy" => "Wyoming",
      "dc" => "District of Columbia",
      "pr" => "Puerto Rico",
      "vi" => "Virgin Islands",
      "gu" => "Guam",
      "as" => "American Samoa",
      "mp" => "Northern Mariana Islands",
    }

    def setup : Nil
      @name = "create"
      @summary = "Create new project directory"
      @description = "Generate FAA-compliant project directory structure"
      @usage = ["project_dir create <jcn> <state> [city] [locid] [factype] [title]"]

      add_argument "jcn", description: "Job Control Number (required)", required: true
      add_argument "state", description: "State (abbreviation or full name)", required: true
      add_argument "city", description: "City name"
      add_argument "locid", description: "Location ID"
      add_argument "factype", description: "Facility type"
      add_argument "title", description: "Optional title to include in dirname"
    end

    def run(arguments : Cling::Arguments, options : Cling::Options) : Nil
      # Check for required arguments first
      missing = [] of ::String
      missing << "jcn" unless arguments.has?("jcn")
      missing << "state" unless arguments.has?("state")

      unless missing.empty?
        error "Missing required arguments: #{missing.join(", ")}"
        exit 1
      end

      # Get required arguments
      jcn = arguments.get("jcn").to_s.strip
      state_input = arguments.get("state").to_s.strip
      state = convert_state(state_input)

      # Get optional arguments with prompts
      city = arguments.get?("city").try(&.to_s.strip) || self.class.prompt.ask("Enter city name:", required: true).not_nil!.gsub(' ', '_')
      locid = arguments.get?("locid").try(&.to_s.strip) || self.class.prompt.ask("Enter location ID:", required: true).not_nil!
      factype = arguments.get?("factype").try(&.to_s.strip) || self.class.prompt.ask("Enter facility type:", required: true).not_nil!
      title = arguments.get?("title").try(&.to_s.strip) || self.class.prompt.ask("Enter optional title")

      title = title.to_s if title

      config = Config.load
      faa_dir = Faa::Dir.new(
        active_project_lib: config.active_project_library_path,
        working_dir: config.working_project_directory_path
      )
      project_dir = faa_dir.find_or_create_project_dir(
        state: state,
        jcn: jcn,
        city: city,
        locid: locid,
        factype: factype,
        title: title
      )

      # Generate directory path

      info "Successfully created project directory: #{project_dir.path.colorize.green}"
    rescue ex : File::Error
      error "Failed to create directory: #{ex.message}"
      exit 1
    end

    private def convert_state(input : ::String) : ::String
      # Try abbreviation first (case-insensitive)
      if input.size == 2
        if full_name = STATE_MAPPINGS[input.downcase]?
          return full_name
        end
      end

      # Try full state name (case-insensitive)
      input_lower = input.downcase
      STATE_MAPPINGS.each do |_, name|
        if name.downcase == input_lower
          return name
        end
      end

      # No matches found
      error "Invalid state: #{input.colorize.red}"
      error "Must be one of:"
      error "  - 2-letter abbreviation (#{STATE_MAPPINGS.keys.join(", ")})"
      error "  - Full state name (e.g. #{STATE_MAPPINGS.values.sample(3).join(", ")})"
      exit 1
    end
  end
end
