require File.dirname(__FILE__) + "/helper/spec_helper.rb"

describe "Verify any issues with multiple rules on a single page" do
  include SPEC_HELPER

  before(:all) do
    load_settings

  end

  after(:all) do
  end


  describe "Verify General Multi Rule Functionality" do

    before(:each) do
      start_browser_session(@settings, "http://www.google.com", "")
    end

    after(:each) do
      end_browser_session
    end

    it "should fire both rules only once when inserted single config to KOBJ_config object " do
      insert_runtime_script(["a685x3","a685x4"])
#      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='kGrowl']"});
#      page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "window.$KOBJ('.KOBJ_header').length == 2"});
      page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
      page.wait_for({:wait_for => :condition , :javascript => "window.$KOBJ('.KOBJ_header').length == 2"});

      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[0]).html()").to_s.should == "MultiAppTestOne"
      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[1]).html()").to_s.should == "MultiAppTestTwo"
    end


    it "should fire both rules only once when inserted with runtime API KOBJ.add_app_configs " do
       insert_runtime_script_no_app()

      # Add the configuration for both applications
      page.js_eval("window.KOBJ.add_app_config({rids:['a685x3','a685x4']});")

      # Run only the first application
      page.js_eval("window.KOBJ.get_application('a685x3').run()")
       
#      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='kGrowl']"});
#      page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "window.$KOBJ('.KOBJ_header').length == 1"});
       page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
       page.wait_for({:wait_for => :condition, :javascript => "window.$KOBJ('.KOBJ_header').length == 1"});
      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[0]).html()").to_s.should == "MultiAppTestOne"

       # Run only the second application
      page.js_eval("window.KOBJ.get_application('a685x4').run()")

#      page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "window.$KOBJ('.KOBJ_header').length == 2"});
      page.wait_for({:wait_for => :condition , :javascript => "window.$KOBJ('.KOBJ_header').length == 2"});
      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[1]).html()").to_s.should == "MultiAppTestTwo"
    end

    it "should fire both rules only once when inserted with runtime API KOBJ.add_app_configs " do
       insert_runtime_script_no_app()

      # Add the configuration for both applications
      page.js_eval("window.KOBJ.add_app_config({rids:['a685x3','a685x4']});")

      # Run only the first application
      page.js_eval("window.KOBJ.get_application('a685x3').run()")

#      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='kGrowl']"});
#      page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "window.$KOBJ('.KOBJ_header').length == 1"});
       page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
       page.wait_for({:wait_for => :condition, :javascript => "window.$KOBJ('.KOBJ_header').length == 1"});
      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[0]).html()").to_s.should == "MultiAppTestOne"

       # Run only the second application
      page.js_eval("window.KOBJ.get_application('a685x4').run()")

#      page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "window.$KOBJ('.KOBJ_header').length == 2"});
      page.wait_for({:wait_for => :condition, :javascript => "window.$KOBJ('.KOBJ_header').length == 2"});
      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[1]).html()").to_s.should == "MultiAppTestTwo"
    end

    it "should fire one rule only once and the second one two times " do
       insert_runtime_script_no_app()

      # Add the configuration for both applications
      page.js_eval("window.KOBJ.add_app_config({rids:['a685x3','a685x4']});")

      # Run only the first application
      page.js_eval("window.KOBJ.get_application('a685x3').run()")

#      page.wait_for({:wait_for => :element, :timeout_in_seconds => 30, :element => "//*[@id='kGrowl']"});
#      page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "window.$KOBJ('.KOBJ_header').length == 1"});
       page.wait_for({:wait_for => :element,  :element => "//*[@id='kGrowltop-right']"});
       page.wait_for({:wait_for => :condition , :javascript => "window.$KOBJ('.KOBJ_header').length == 1"});
      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[0]).html()").to_s.should == "MultiAppTestOne"

       # Run only the second application
      page.js_eval("window.KOBJ.get_application('a685x4').run()")

#      page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "window.$KOBJ('.KOBJ_header').length == 2"});
      page.wait_for({:wait_for => :condition ,  :javascript => "window.$KOBJ('.KOBJ_header').length == 2"});
      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[1]).html()").to_s.should == "MultiAppTestTwo"

       # Run only the second application
      page.js_eval("window.KOBJ.get_application('a685x4').run()")

#      page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "window.$KOBJ('.KOBJ_header').length == 3"});
      page.wait_for({:wait_for => :condition , :javascript => "window.$KOBJ('.KOBJ_header').length == 3"});
      page.js_eval("window.$KOBJ(window.$KOBJ('.KOBJ_header')[2]).html()").to_s.should == "MultiAppTestTwo"
      # Site ID is the combination of all the apps seperated by a ;
      page.js_eval("window.KOBJ.site_id()").to_s.should == "a685x3;a685x4"
    end

  end
end