require File.dirname(__FILE__) + "/helper/spec_helper.rb"



describe "Verify Runtime Functions" do
  include SPEC_HELPER

  before(:all) do
    load_settings
    start_browser_session(@settings, "http://k-misc.s3.amazonaws.com", "/runtime-dependencies/allcrapptest.html")
    insert_runtime_script(["a685x1"])
    page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='kGrowl']"});
  end

  after(:all) do
    end_browser_session
  end


  describe "search.yahoo.com" do

    before(:each) do
    end

    after(:each) do

    end

  end


  it "should have shown a kGrowl Notify" do
     page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='kGrowl']"});
     page.text("//div[@class='KOBJ_message']").should == "This is a sample rule."
  end

  it "should replace element value" do
     page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='mychangeelement']"});
     page.text("//*[@id='mychangeelement']/@value").should == "Ihavechanged"
  end

  it "should have appended text to div with id of area9" do
     page.text("//div[@id='area9']").should == "prepend to area 9Area 9added to area 9"
  end

  it "should have prepend text to div with id of area9" do
     page.text("//div[@id='area9']").should == "prepend to area 9Area 9added to area 9"
  end
  
  it "should have added a div after area 9" do
     page.text("//div[@id='area10']/preceding-sibling::*[position() = 1]").should == "prepend to area 9Area 9added to area 9"
  end

  it "should have added a div before area 9" do
     page.text("//div[@id='area9']/preceding-sibling::*[position() = 1]").should == "data before area 9"
  end


  it "should have floated the floattext.html file" do
     page.text("//div[@id='floathtml']").should == "this is text from the float html"
  end
  
  it "should have moved area2 after area 4" do
     page.text("//div[@id='area2']/preceding-sibling::*[position() = 1]").should == "Area 4"
  end

  it "should have floated html text" do
     page.text("//h1[@id='floatid']").should == "I'm Floating HTML!"
  end


  it "should have moved area 5 to the top of the page." do
     page.text("//div[@id='area5']/following-sibling::*[position() = 1]").should == "TopOfPage"
  end


  it "should have replace area 6 contents with new area 6." do
     page.text("//div[@id='newarea6replace']").should == "new area 6"
  end
  

  it "should have replace area 7 with replacetext.html." do
     page.text("//div[@id='newarea7']").should == "this is text from the replace html"
  end

  it "should have replace area 8 contents." do
     page.text("//div[@id='area8']").should == "The content has been replaced"
  end


#  it "should have replace the source image url." do
#     page.text("//img[@id='myimage']/@src").should == "http://k-misc.s3.amazonaws.com/runtime-dependencies/Asshole_20Watcher.jpg"
#  end
  
end