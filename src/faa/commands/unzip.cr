module Faa::Commands
  class Unzip < Base
    def setup_ : Nil
      @name = "unzip"
      @description = "Extract ZIP archive to directory"
      add_argument "zipfile", description: "Path to ZIP archive"
      add_argument "outdir", description: "Output directory path"

      add_option 'f', "force", description: "Overwrite existing files"
    end

    def run_(arguments : Cling::Arguments, options : Cling::Options) : Nil
      Faa::Utils.unzip(
        arguments.get("zipfile").as_s,
        arguments.get("outdir").as_s
      )
      puts "Successfully extracted to #{arguments.get("outdir").as_s}"
    end
  end
end
