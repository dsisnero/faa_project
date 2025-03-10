require "../spec_helper"

describe Faa::Commands::Create do
  describe "directory creation" do
    it "creates path with title containing spaces" do
      with_test_config do |config|
        with_mocked_prompts do
          command = Faa::Commands::Create.new
          command.run(
            Cling::Arguments.new(["25007323", "ut"]),
            Cling::Options.new({"title" => "RTIR SITE PREP"})
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

      expect_raises(Cling::MissingArguments, /jcn/) do
        command.run(Cling::Arguments.new(["ut"]), Cling::Options.new)
      end

      expect_raises(Cling::MissingArguments, /state/) do
        command.run(Cling::Arguments.new(["25007323"]), Cling::Options.new)
      end
    end
  end
end
