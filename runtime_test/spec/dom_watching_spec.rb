require File.dirname(__FILE__) + "/helper/spec_helper.rb"


describe "Dom Watching Specs" do
  include SPEC_HELPER

  before(:all) do
    load_settings
  end

  before(:each) do
    start_browser_session(@settings, "http://search.yahoo.com", "/")
  end

  after(:each) do
    end_browser_session
  end
  
  it "Domwatch Test" do
    start_browser_session(@settings, "http://k-misc.s3.amazonaws.com", "/runtime-dependencies/domWatch.html")
    insert_runtime_script(["a41x91"])
#    page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//div[@id='kobj_loaded']"});
    page.wait_for({:wait_for => :element, :element => "//div[@id='kobj_loaded']"});
    page.click "domTestClicker", :wait_for => :element, :element => 'domTestWorked'
  end


end