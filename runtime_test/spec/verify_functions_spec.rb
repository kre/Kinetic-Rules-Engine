require File.dirname(__FILE__) + "/helper/spec_helper.rb"



describe "Verify Runtime Functions" do
  include SPEC_HELPER

  before(:all) do
    load_settings
    start_browser_session(@settings, "http://search.yahoo.com", "/")
    insert_runtime_script(["a41x27"])
    page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='KOBJ_after']"});
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
    page.js_eval("'' + (typeof(window.KOBJ.log) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.location" do
    page.js_eval("typeof(window.KOBJ.location) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.css" do
    page.js_eval("'' + (typeof(window.KOBJ.css) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.errorstack_submit" do
    page.js_eval("'' + (typeof(window.KOBJ.errorstack_submit) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.logger" do
    page.js_eval("'' + (typeof(window.KOBJ.logger) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.obs" do
    page.js_eval("'' + (typeof(window.KOBJ.obs) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.fragment" do
    page.js_eval("'' + (typeof(window.KOBJ.fragment) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.update_elements" do
    page.js_eval("'' + (typeof(window.KOBJ.update_elements) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.Fade" do
    page.js_eval("'' + (typeof(window.KOBJ.Fade) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.BlindDown" do
    page.js_eval("'' + (typeof(window.KOBJ.BlindDown) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.BlindUp" do
    page.js_eval("'' + (typeof(window.KOBJ.BlindUp) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.BlindUp" do
    page.js_eval("'' + (typeof(window.KOBJ.BlindUp) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.hide" do
    page.js_eval("'' + (typeof(window.KOBJ.hide) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.letitsnow" do
    page.js_eval("'' + (typeof(window.KOBJ.letitsnow) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.createPopIn" do
    page.js_eval("'' + (typeof(window.KOBJ.createPopIn) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.statusbar" do
    page.js_eval("'' + (typeof(window.KOBJ.statusbar) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.statusbar_close" do
    page.js_eval("'' + (typeof(window.KOBJ.statusbar_close) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.buildDiv" do
    page.js_eval("'' + (typeof(window.KOBJ.buildDiv) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.get_host" do
    page.js_eval("'' + (typeof(window.KOBJ.get_host) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.close_notification" do
    page.js_eval("'' + (typeof(window.KOBJ.close_notification) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.getwithimage" do
    page.js_eval("'' + (typeof(window.KOBJ.getwithimage) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.require" do
    page.js_eval("'' + (typeof(window.KOBJ.require) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.reload" do
    page.js_eval("'' + (typeof(window.KOBJ.reload) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.eval" do
    page.js_eval("'' + (typeof(window.KOBJ.eval) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.init" do
    page.js_eval("'' + (typeof(window.KOBJ.init) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.registerDataSet" do
    page.js_eval("'' + (typeof(window.KOBJ.registerDataSet) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.registerClosure" do
    page.js_eval("'' + (typeof(window.KOBJ.registerClosure) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.clearExecutionDelay" do
    page.js_eval("'' + (typeof(window.KOBJ.clearExecutionDelay) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.executeWhenReady" do
    page.js_eval("'' + (typeof(window.KOBJ.executeWhenReady) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.executeClosure" do
    page.js_eval("'' + (typeof(window.KOBJ.executeClosure) == 'function')").should match(/true/)
  end



  it "have defined a function called KOBJ.percolate" do
    page.js_eval("'' + (typeof(window.KOBJ.percolate) == 'function')").should match(/true/)
  end



  it "have defined a function called KOBJ.watchDOM" do
    page.js_eval("'' + (typeof(window.KOBJ.watchDOM) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.splitJSONRequest" do
    page.js_eval("'' + (typeof(window.KOBJ.splitJSONRequest) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.getJSONP" do
    page.js_eval("'' + (typeof(window.KOBJ.getJSONP) == 'function')").should match(/true/)
  end

  it "have defined a function called KOBJ.annotate_local_search_extractdata" do
    page.js_eval("'' + (typeof(window.KOBJ.annotate_local_search_extractdata) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.annotate_local_search_results" do
    page.js_eval("'' + (typeof(window.KOBJ.annotate_local_search_results) == 'function')").should match(/true/)
  end


  it "have defined a function called KOBJ.annotate_search_extractdata" do
    page.js_eval("'' + (typeof(window.KOBJ.annotate_search_extractdata) == 'function')").should match(/true/)
  end



  it "have defined a function called KOBJ.annotate_search_results" do
    page.js_eval("'' + (typeof(window.KOBJ.annotate_search_results) == 'function')").should match(/true/)
  end


  it "have defined a function called $K.kGrowl" do
    page.js_eval("'' + (typeof(window.$K.kGrowl) == 'function')").should match(/true/)
  end


  it "have defined a function called $K.kGrowl" do
    page.js_eval("'' + (typeof(window.$K.tabSlideOut) == 'function')").should match(/true/)
  end

end