require File.dirname(__FILE__) + "/helper/spec_helper.rb"

describe "Verify Hi Conflict Sites" do
  include SPEC_HELPER

  before(:all) do
    load_settings

  end

  describe "Google Docs" do

    before(:each) do
      start_browser_session(@settings, "https://www.google.com", "/accounts/ServiceLogin?service=writely&passive=1209600&continue=http://docs.google.com/&followup=http://docs.google.com/&ltmpl=homepage&browserok=true")
      page.type("Email","autojam@kynetx.com")
      page.type('Passwd',"Kynetx123$")
      page.submit('gaia_loginform');
      # Wait to see the search box. If we are there then we are in.
#      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='doclist']"});
      page.wait_for({:wait_for => :element, :element => "//*[@id='doclist']"});
      insert_runtime_script(["a685x1"])
    end

    after(:each) do
      end_browser_session
    end

    it "should have shown a kGrowl Notify" do
#       page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='kGrowl']"});
       page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
       page.text("//div[@class='KOBJ_message']").should == "This is a sample rule."
    end

  end

  describe "Prototype JS Page" do

    before(:each) do
      start_browser_session(@settings, "http://api.prototypejs.org", "/")
      # Wait to see the search box. If we are there then we are in.
#      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='sidebar']"});
      page.wait_for({:wait_for => :element, :element => "//*[@id='sidebar']"});
      insert_runtime_script(["a685x1"])
    end

    after(:each) do
      end_browser_session
    end

    it "should have shown a kGrowl Notify" do
#       page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='kGrowl']"});
       page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
       page.text("//div[@class='KOBJ_message']").should == "This is a sample rule."
    end

  end

end