path = File.expand_path(File.dirname(__FILE__))
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'spec_helper')

describe Fdoc do
  before(:each) do
    Fdoc.load(FIXTURES_PATH)
  end

  after(:each) do
    Fdoc.clear
  end

  describe "#resource_for" do
    context "when a there is a resource for that controller" do
      it "should return a Resource object wrapping that file" do
        Fdoc.resource_for("Api::MembersController").should be_kind_of Fdoc::Resource
      end
    end

    context "when there is not a resource for that controller" do
      it "should return nil" do
        Fdoc.resource_for("Api::UnknownController").should be_nil
      end
    end
  end

  describe "#scaffold_for" do
    it "should create resource object for that controller and add it to the module" do
      Fdoc.resource_for("Api::SillyGooseController").should be_nil
      Fdoc.scaffold_for("Api::SillyGooseController").should be_kind_of Fdoc::Resource
    end

    it "should attempt to guess the resource name based on the controller name" do
      Fdoc.scaffold_for("Api::PaymentsController").name.should == "payments"
      Fdoc.scaffold_for("Api::ComplicatedResourceTypeController").name.should == "complicated_resource_type"
    end

    it "should raise an exception when the real resource already exists" do
      expect { Fdoc.scaffold_for("Api::MembersController") }.to raise_exception(Fdoc::ResourceAlreadyExistsError)
    end
  end

  describe "#compile" do
    it "returns a valid HTML string" do
      html = Fdoc.compile("members", "/docs")
      html.should be_kind_of String

      parser = LibXML::XML::HTMLParser.string(html)
      parser.parse.should be_kind_of LibXML::XML::Document
    end
  end

  describe "#compile_index" do
    it "returns a valid HTML string" do
      html = Fdoc.compile_index("/docs")
      html.should be_kind_of String

      parser = LibXML::XML::HTMLParser.string(html)
      parser.parse.should be_kind_of LibXML::XML::Document
    end
  end

  describe "::schema" do
    it "loads and returns the fdoc schema" do
      Fdoc.schema.should == YAML.load_file(File.join(File.dirname(__FILE__), "../../fdoc-schema.yaml"))
    end
  end
end
