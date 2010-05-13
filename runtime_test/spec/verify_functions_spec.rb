require File.dirname(__FILE__) + "/helper/spec_helper.rb"



describe "Verify Runtime Functions" do
  include SPEC_HELPER

  before(:all) do
    load_settings
    start_browser_session(@settings, "http://search.yahoo.com", "/")
    insert_runtime_script(["a41x27"])
    page.wait_for({:wait_for => :element, :timeout_in_seconds => 300, :element => "//*[@id='KOBJ_after']"});
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


  it "have defined a function called KOBJ.log" do
    page.js_eval("'' + (typeof(window.KOBJ.log) != 'undefined')").to_s.should == "true"
  end

#  it "have defined a function called KOBJ.location" do
#    page.js_eval("typeof(window.KOBJ.location)  != 'undefined')").should == "true"
#  end

  it "have defined a function called KOBJ.css" do
    page.js_eval("'' + (typeof(window.KOBJ.css)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.errorstack_submit" do
    page.js_eval("'' + (typeof(window.KOBJ.errorstack_submit)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.logger" do
    page.js_eval("'' + (typeof(window.KOBJ.logger)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.obs" do
    page.js_eval("'' + (typeof(window.KOBJ.obs)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.fragment" do
    page.js_eval("'' + (typeof(window.KOBJ.fragment)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.update_elements" do
    page.js_eval("'' + (typeof(window.KOBJ.update_elements)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.Fade" do
    page.js_eval("'' + (typeof(window.KOBJ.Fade)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.BlindDown" do
    page.js_eval("'' + (typeof(window.KOBJ.BlindDown)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.BlindUp" do
    page.js_eval("'' + (typeof(window.KOBJ.BlindUp)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.BlindUp" do
    page.js_eval("'' + (typeof(window.KOBJ.BlindUp)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.hide" do
    page.js_eval("'' + (typeof(window.KOBJ.hide)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.letitsnow" do
    page.js_eval("'' + (typeof(window.KOBJ.letitsnow)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.createPopIn" do
    page.js_eval("'' + (typeof(window.KOBJ.createPopIn)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.statusbar" do
    page.js_eval("'' + (typeof(window.KOBJ.statusbar)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.statusbar_close" do
    page.js_eval("'' + (typeof(window.KOBJ.statusbar_close)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.buildDiv" do
    page.js_eval("'' + (typeof(window.KOBJ.buildDiv)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.get_host" do
    page.js_eval("'' + (typeof(window.KOBJ.get_host)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.close_notification" do
    page.js_eval("'' + (typeof(window.KOBJ.close_notification)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.getwithimage" do
    page.js_eval("'' + (typeof(window.KOBJ.getwithimage)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.require" do
    page.js_eval("'' + (typeof(window.KOBJ.require)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.reload" do
    page.js_eval("'' + (typeof(window.KOBJ.reload)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.eval" do
    page.js_eval("'' + (typeof(window.KOBJ.eval)  != 'undefined')").to_s.should == "true"
  end

#  it "have defined a function called KOBJ.init" do
#    page.js_eval("'' + (typeof(window.KOBJ.init)  != 'undefined')").should == "true"
#  end


  it "have defined a function called KOBJ.registerDataSet" do
    page.js_eval("'' + (typeof(window.KOBJ.registerDataSet)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.registerClosure" do
    page.js_eval("'' + (typeof(window.KOBJ.registerClosure)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.clearExecutionDelay" do
    page.js_eval("'' + (typeof(window.KOBJ.clearExecutionDelay)  != 'undefined')").to_s.should == "true"
  end

#  it "have defined a function called KOBJ.executeWhenReady" do
#    page.js_eval("'' + (typeof(window.KOBJ.executeWhenReady)  != 'undefined')").should == "true"
#  end


#  it "have defined a function called KOBJ.executeClosure" do
#    page.js_eval("'' + (typeof(window.KOBJ.executeClosure)  != 'undefined')").should == "true"
#  end



  it "have defined a function called KOBJ.percolate" do
    page.js_eval("'' + (typeof(window.KOBJ.percolate)  != 'undefined')").to_s.should == "true"
  end



  it "have defined a function called KOBJ.watchDOM" do
    page.js_eval("'' + (typeof(window.KOBJ.watchDOM)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.splitJSONRequest" do
    page.js_eval("'' + (typeof(window.KOBJ.splitJSONRequest)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.getJSONP" do
    page.js_eval("'' + (typeof(window.KOBJ.getJSONP)  != 'undefined')").to_s.should == "true"
  end

  it "have defined a function called KOBJ.annotate_local_search_extractdata" do
    page.js_eval("'' + (typeof(window.KOBJ.annotate_local_search_extractdata)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called KOBJ.annotate_local_search_results" do
    page.js_eval("'' + (typeof(window.KOBJ.annotate_local_search_results)  != 'undefined')").should == "true"
  end


  it "have defined a function called KOBJ.annotate_search_extractdata" do
    page.js_eval("'' + (typeof(window.KOBJ.annotate_search_extractdata)  != 'undefined')").to_s.should == "true"
  end



  it "have defined a function called KOBJ.annotate_search_results" do
    page.js_eval("'' + (typeof(window.KOBJ.annotate_search_results)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called $KOBJ.kGrowl" do
    page.js_eval("'' + (typeof(window.$KOBJ.kGrowl)  != 'undefined')").to_s.should == "true"
  end


  it "have defined a function called $KOBJ.tabSlideOut" do
    page.js_eval("'' + (typeof(window.$KOBJ.tabSlideOut)  != 'undefined')").to_s.should == "true"
  end

end