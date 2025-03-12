require "../spec_helper"

describe Faa::Commands::Create do
  describe "directory creation" do
    it "creates path with title containing spaces" do
      with_test_config do |config|
        with_mocked_prompts do
          command = Faa::Commands::Create.new
          command.run(
            Cling::Arguments.new({
              "jcn" => Cling::Argument.new("25007323"),
              "state" => Cling::Argument.new("ut"),
              "city" => Cling::Argument.new("TestCity"),
              "locid" => Cling::Argument.new("TLOC"),
              "factype" => Cling::Argument.new("Test"),
              "title" => Cling::Argument.new("RTIR SITE PREP")
            }),
            Cling::Options.new({} of String => Cling::Option)
          )

          expected = File.join(
            config.working_project_directory_path,
            "25007323_utah_testcity_tloc_test_rtir_site_prep"
          )
          Dir.exists?(expected).should be_true
        end
      end
    end
  end

  describe "argument validation" do
    it "requires jcn and state" do
      command = Faa::Commands::Create.new
      
      # Test missing jcn
      output = capture_stderr do
        exit_code = capture_exit_code do
          command.run(
            Cling::Arguments.new({"state" => Cling::Argument.new("ut")}),
            Cling::Options.new({} of String => Cling::Option)
          )
        end
        exit_code.should eq(1)
      end
      output.should contain("Missing required arguments: jcn")

      # Test missing state
      output = capture_stderr do
        exit_code = capture_exit_code do
          command.run(
            Cling::Arguments.new({"jcn" => Cling::Argument.new("25007323")}),
            Cling::Options.new({} of String => Cling::Option)
          )
        end
        exit_code.should eq(1)
      end
      output.should contain("Missing required arguments: state")
    end
  end
end
