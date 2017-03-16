require "spec_helper"

describe "Ruby I18N" do

  let(:fixtures_path) { Pathname.new(File.expand_path("../fixtures", __FILE__)) }

  before(:all) do
    I18n.load_path << fixtures_path.join("en.asf")
    I18n.load_path << fixtures_path.join("sample.yml")

    # The ASF file is en-US, YAML is just 'en'; ASF translations will have
    # precedence but YAML translations will be available as fallbacks.
    # In practice, ASF translations should be :en by default, with regional
    # variations (en-GB, en-AU) used as overrides to cover edge cases, though
    # wherever possible the standard English versions should be written so
    # as to be appropriate for all English-speaking regions.
    # U.S. spelling or semantic conventions, e.g. 'color' not 'colour', are
    # acceptable.
    I18n.default_locale = :en
    I18n.locale = :"en-US"
  end

  describe "loading ASF translations" do
    let(:translations) { I18n.backend.send(:translations) }

    before do
      I18n.backend.send(:init_translations)
    end

    it "reads locale from the ASF markup if present" do
      translations[:"en-US"][:simple].should == "Add to Kit"
    end
  end

  specify "using translations from ASF" do
    I18n.t("simple").should == "Add to Kit"
    I18n.t("with-interpolation", :invoice_total => "$49.99").should == "Invoice total: $49.99"
    I18n.t("backend.nested-string").should == "I'm in the backend"
  end

  describe "using ASF and YAML strings together" do
    it "can use YAML for fallbacks" do
      I18n.t("hello_yaml").should == "Hello YAML!"
    end
    it "prefers the current locale if the same string is present in both" do
      I18n.t("propsets").should == "Hello world!"
    end
  end
end