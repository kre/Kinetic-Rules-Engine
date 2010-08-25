require File.dirname(__FILE__) + "/helper/spec_helper.rb"



describe "Verify Raise Events" do
  include SPEC_HELPER

  before(:all) do
    load_settings
    start_browser_session(@settings, "http://www.google.com", "/")
  end

  after(:all) do
    end_browser_session
  end



  it "should have shown two notifies one from each rule fired" do
    insert_runtime_script(["a685x5"])
    page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
    page.text("//div[@class='KOBJ_message']").should == "second_rule"
  end

end