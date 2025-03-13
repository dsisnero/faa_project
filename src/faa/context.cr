module Faa
  class Context
    def initialize(@stdout : IO, @config : Configuration, @display : Display, @input : Input, @faa_dir : Dir); end

    getter stdout : IO
    getter config : Configuration
    getter display : Display
    getter input : Input
    getter faa_dir : Dir
  end
end
