require File.dirname(__FILE__) + "/helper/spec_helper.rb"

describe "Verify Google Docs and Gmail" do
  include SPEC_HELPER

  before(:all) do
    load_settings
    
    start_browser_session(@settings, "https://www.google.com", "/accounts/ServiceLogin?service=mail&passive=true&rm=false&continue=http://mail.google.com/mail/%3Fhl%3Den%26tab%3Dwm%26ui%3Dhtml%26zy%3Dl&bsv=1eic6yu9oa4y3&scc=1&ltmpl=default&ltmplcache=2&hl=en")
    page.type("Email","cid.dennis@gmail.com")
    page.type('Passwd',"men-aCe")
    page.submit('gaia_loginform');
    # Wait to see the search box. If we are there then we are in.
    page.wait_for({:wait_for => :element, :timeout_in_seconds => 20, :element => "//*[@id='hist_state']"});
    insert_runtime_script(["a685x1"])
  end

  after(:all) do
    end_browser_session
  end


  describe "Alter Gmail Screen" do

    before(:each) do
    end

    after(:each) do

    end

    it "should have shown a kGrowl Notify" do
       page.wait_for({:wait_for => :element, :timeout_in_seconds => 20, :element => "//*[@id='kGrowltop-right']"});
       page.text("//div[@class='KOBJ_message']").should == "This is a sample rule."
    end

  end
end