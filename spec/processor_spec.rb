# -*- encoding: utf-8 -*-
require 'spec_helper'

describe "ASF processor" do
  let(:fixtures_path) { Pathname.new(File.expand_path("../fixtures", __FILE__)) }
  let(:asf_source) { fixtures_path.join("en.asf").read }
  let(:processor) { I18n::ASF::Processor.new }

  def parse_asf_string(*args)
    processor.process_string_node(*args)
  end

  describe "initialization" do
    specify "from XML data" do
      Nokogiri.should_receive(:XML).with(asf_source).and_return(mock('Nokogiri', :children => []))
      processor.process_document(asf_source)
    end
    specify "from an IO object" do
      mock_file = mock('IO', :read => asf_source)
      Nokogiri.should_receive(:XML).with(mock_file).and_return(mock('Nokogiri', :children => []))
      processor.process_document(mock_file)
    end
  end

  describe "metadata" do
    it "includes a locale attribute" do
      data = processor.process_document(asf_source)
      data.should have_key("_locale")
      data["_locale"].should == "en-US"
    end
  end

  describe "parsing" do
    specify "a basic string" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=simple]")
      key, value = parse_asf_string(string_node)
      key.should == "simple"
      value.should == "Add to Kit"
    end

    specify "a string with HTML entities" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=with-html-entity]")
      key, value = parse_asf_string(string_node)
      value.should == "Adobe&reg; Photoshop&reg; Lightroom&trade;"
    end

    specify "a string with Unicode characters" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=with-unicode]")
      key, value = parse_asf_string(string_node)
      value.should == "Adobe® Photoshop® Lightroom™"
    end

    specify "a string with interpolated parameter" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=with-interpolation]")
      key, value = parse_asf_string(string_node)
      value.should == "Invoice total: %{invoice_total}"
    end

    specify "a string with nested DNT (do not translate) element" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=with-dnt]")
      key, value = parse_asf_string(string_node)
      value.should == "Copyright %{year} Typekit"
    end

    specify "a string with params nested inside a DNT" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=dnt-with-nested-param]")
      key, value = parse_asf_string(string_node)
      value.should == "Hello! Typekit is %{awesome}!"
    end

    specify "a string with embedded HTML" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=embedded-html]")
      key, value = parse_asf_string(string_node)
      value.should == "Your subscription is <b>Past Due since %{date}</b>"
    end

    specify "a string with entity-encoded HTML" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=encoded-html]")
      key, value = parse_asf_string(string_node)
      value.should == "Your subscription is <b>Past Due since %{date}</b>"
    end

    specify "strings with multiple values" do
      string_node = Nokogiri::XML(asf_source).at("asf str[name=multi-value]")
      key, value = parse_asf_string(string_node)
      value.should == "Hello world!"
    end

    specify "a string set" do
      set_node = Nokogiri::XML(asf_source)
      hash = processor.process_document(set_node)
      hash["backend"].should_not be_nil
      hash.should include({
        "backend" => {
          "nested-string" => "I'm in the backend"
        }
      })
    end
  end

end