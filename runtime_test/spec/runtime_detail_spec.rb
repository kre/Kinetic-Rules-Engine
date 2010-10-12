require File.dirname(__FILE__) + "/helper/spec_helper.rb"



describe "Verify Runtime Functions" do
  include SPEC_HELPER

  before(:each) do
    load_settings
    start_browser_session(@settings, "http://www.google.com", "/")
    insert_runtime_script(["a685x9"])
    # Wait for runtime to load
    page.wait_for_condition("typeof(window.$KOBJ) != 'undefined'",20);

  end

  after(:each) do
    end_browser_session
  end


  it "have ability to get application from runtime" do
    JS =<<EOF
      (window.KOBJ.get_application("a685x9") != null)
EOF

    page.js_eval( JS ).to_s.should == "true"
  end



  it "have add extra page variable to runtime" do
    JS =<<EOF
      window.KOBJ.add_extra_page_var("test","joe");
      (window.KOBJ['extra_page_vars']["test"] == "joe");

EOF

    page.js_eval( JS ).to_s.should == "true"
  end
  

  it "have add extra page variable to runtime" do
    JS =<<EOF
      window.KOBJ.add_extra_page_var("test","joe");
      (window.KOBJ['extra_page_vars']["test"] == "joe");

EOF

    page.js_eval( JS ).to_s.should == "true"
  end
  

  it "have should not add page var if start with init or rids" do
    JS =<<EOF
      window.KOBJ.add_extra_page_var("init:test","joe");
      window.KOBJ.add_extra_page_var("rids:test","joe");
      (window.KOBJ['extra_page_vars']["init:test"] == null  && window.KOBJ['extra_page_vars']["rids:test"] == null);

EOF

    page.js_eval( JS ).to_s.should == "true"
  end


  it "have should generate url version of page vars" do
    JS =<<EOF
      window.KOBJ.add_extra_page_var("test","joe");
      (window.KOBJ.extra_page_vars_as_url() == "&test=joe");

EOF

    page.js_eval( JS ).to_s.should == "true"
  end


  it "have should run requested prod app" do
    JS =<<EOF
      window.KOBJ.add_config_and_run({rids:["a685x7"]});
EOF

    page.js_eval( JS )

     page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
     page.text("//div[@class='KOBJ_message']").should == "Hello prod World"

    
  end

  it "have should run requested dev app" do
    JS =<<EOF
      window.KOBJ.add_config_and_run({'a685x8:kynetx_app_version':'dev',rids:["a685x8"]});
EOF

    page.js_eval( JS )

     page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
     page.text("//div[@class='KOBJ_message']").should == "Simple Dev rule."


  end

  it "have should run multiple requested  app" do
    JS =<<EOF
      window.KOBJ.add_config_and_run({'a685x8:kynetx_app_version':'dev',rids:["a685x7","a685x8"]});
EOF

    page.js_eval( JS )

     page.wait_for({:wait_for => :element, :element => "//*[@id='kGrowltop-right']"});
     page.wait_for_condition("window.$KOBJ('.KOBJ_message').text() == 'Hello prod WorldSimple Dev rule.'",20);


  end


  it "have should configure multiple requested  app" do
    JS =<<EOF
      window.KOBJ.add_app_configs([{rids:["a685x7"]},{rids:["a685x8"]}]);
EOF

    page.js_eval( JS )
    page.js_eval( "(window.KOBJ.get_application('a685x7') != null ) " ).to_s.should == "true"
    page.js_eval( "( window.KOBJ.get_application('a685x8') != null ) " ).to_s.should == "true"

  end


  it "have should configure single requested  app" do
    JS =<<EOF
      window.KOBJ.add_app_config({rids:["a685x7"]});
EOF

    page.js_eval( JS )
    page.js_eval( "(window.KOBJ.get_application('a685x7') != null ) " ).to_s.should == "true"

  end

  it "have site id made up of all currently configured apps" do
    JS =<<EOF
     window.KOBJ.add_app_configs([{rids:["a685x7"]},{rids:["a685x8"]}]);
EOF

    page.js_eval( JS )
    page.js_eval( "(window.KOBJ.site_id() == 'a685x9;a685x7;a685x8' ) " ).to_s.should == "true"

  end

  it "have load external javascript resource" do
    JS =<<EOF
     window.KOBJ.registerExternalResources("a685x9",{"https://kresources.kobj.net/jquery_ui/1.8/jquery-ui-1.8.4.custom.min.js": {"type":"js"}});
EOF

    page.js_eval( JS )
    page.wait_for_condition( "window.KOBJ.external_resources['http://kresources.kobj.net/jquery_ui/1.8/jquery-ui-1.8.4.custom.min.js'].loaded" )

  end


  it "have check protocol of browser" do

    page.js_eval( "window.KOBJ.proto() == 'http://'" ).to_s.should == "true"
    

  end


  it "have check gethost" do

    page.js_eval( "window.KOBJ.get_host('http://www.google.com') == 'www.google.com'" ).to_s.should == "true"


  end

  it "have check location" do

    page.js_eval( "window.KOBJ.location('protocol') == 'http:'" ).to_s.should == "true"
    page.js_eval( "window.KOBJ.location('host') == 'www.google.com'" ).to_s.should == "true"


  end

end



