require File.dirname(__FILE__) + "/helper/spec_helper.rb"


#
# Test Search engine annotation rules.
#
describe "Search Test" do
  include SPEC_HELPER

  # All the search result spec all look the same so use a shared example for validation
  shared_examples_for "Any Search" do
    include SPEC_HELPER

    #
    # The rule basicly add phone numbers to the search page and we need to find them
    #
    it "find the added phone numbers" do
      insert_runtime_script(["a41x10"])
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 10, :element => "//div[@id='KOBJ_append_local2']"});
      text_to_try = /(Phone.:8017983217|Phone.:8017987119|Phone.:8017983217|Phone.:8013735713|Phone.:8017940515)/
      page.body_text.should match(text_to_try);
    end

  end

  before(:all) do
    load_settings
  end


  describe "Yahoo Search Annotations" do
    it_should_behave_like "Any Search"

    before(:each) do
      start_browser_session(@settings, "http://search.yahoo.com","/search?p=food+84660")
    end

    after(:each) do
      end_browser_session
    end

  end


  describe "Google Search Annotations" do
    it_should_behave_like "Any Search"

    before(:each) do
      start_browser_session(@settings, "http://www.google.com", "/search?q=food+84660")
    end

    after(:each) do
      end_browser_session
    end

  end

  describe "Bing Search Annotations" do
    it_should_behave_like "Any Search"

    before(:each) do
      start_browser_session(@settings, "http://www.bing.com","/search?q=food+84660")
    end

    after(:each) do
      end_browser_session
    end

  end

  describe "Yahoo Local Search Annotations" do
    it_should_behave_like "Any Search"

    before(:each) do
      start_browser_session(@settings, "http://local.yahoo.com","/results?p=food&csz=84660")
    end

    after(:each) do
      end_browser_session
    end


  end

end
