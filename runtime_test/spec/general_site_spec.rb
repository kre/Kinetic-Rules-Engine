require File.dirname(__FILE__) + "/helper/spec_helper.rb"



describe "General Site Test" do
  include SPEC_HELPER

  # All the search result spec all look the same so use a shared exmaple for validation
  shared_examples_for "Any Site" do
    include SPEC_HELPER

    it "function same on all sites" do

      insert_runtime_script(["a41x27"])
      #  We wait for all the elements as the java script is rendering them so we need to give them time
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_after']"});
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_append']"});
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_before']"});
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_test']"});
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_float_html']"});
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_notify']"});
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_prepend']"});
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_image']"});
      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_close_test']"});

      page.text("//div[@id='KOBJ_app_bef_aft_test']").should == "KOBJ_beforeKOBJ_afterKOBJ_append"

      page.text("//span[@id='KOBJ_float_html']").should == "KOBJ_prependKOBJ_float_html"
      page.js_eval("window.$K('#KOBJ_image').attr('src');").should == "http://k-misc.s3.amazonaws.com/resources/a41x27/image-2.jpg"
      page.click "//div[@id='KOBJ_close_test']"
      page.wait_for({:wait_for => :no_element, :element => "KOBJ_close_test" })
      page.element?("//div[@id='KOBJ_close_test']").should be_false
    end

  end

  before(:all) do
    load_settings
  end


  describe "search.yahoo.com" do
    it_should_behave_like "Any Site"

    before(:each) do
      start_browser_session(@settings, "http://search.yahoo.com", "/")
    end

    after(:each) do
      end_browser_session
    end

  end


  describe "www.google.com" do
    it_should_behave_like "Any Site"

    before(:each) do
      start_browser_session(@settings, "http://www.google.com", "/")
    end

    after(:each) do
      end_browser_session
    end

  end

  describe "www.apple.com" do
    it_should_behave_like "Any Site"

    before(:each) do
      start_browser_session(@settings, "http://www.apple.com", "/")
    end

    after(:each) do
      end_browser_session
    end

  end

  describe "www.bing.com" do
    it_should_behave_like "Any Site"

    before(:each) do
      start_browser_session(@settings, "http://www.bing.com", "/")
    end

    after(:each) do
      end_browser_session
    end

  end

  describe "www.youtube.com" do
    it_should_behave_like "Any Site"

    before(:each) do
      start_browser_session(@settings, "http://www.youtube.com", "/")
    end

    after(:each) do
      end_browser_session
    end

  end

  describe "www.msn.com" do
    it_should_behave_like "Any Site"

    before(:each) do
      start_browser_session(@settings, "http://www.msn.com", "/")
    end

    after(:each) do
      end_browser_session
    end

  end


end