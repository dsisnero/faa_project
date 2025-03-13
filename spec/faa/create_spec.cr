require "../spec_helper"
describe Faa::Commands::Create do
  describe "directory creation" do
    it "creates path with title containing spaces" do
      context = run(["25007323", "ut", "TestCity", "locid", "rtr", "rtir site prep"])
      dir = context.faa_dir.active_project_lib
      project_dir = (dir / "Utah/")
      project_dir.to_s.should eq File.join(dir, "Utah", "25007323")
    end
  end

  describe "argument validation" do
    it "requires jcn and state" do
      context = run(["ut"])
      context.stdout.to_s.should eq("Missing required arguments: state")

      context = run(["ut", "25007323"])
      context.stdout.to_s.should eq("City:")
    end
  end
end
