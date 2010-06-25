require 'rubygems'
require "json"
require "yaml"
require "spec"
require "selenium/client"
require "selenium/rspec/spec_helper"
gem "rspec"
gem "selenium-client"
require "selenium/client"
require "selenium/rspec/spec_helper"

#
# Some helper methods used in Selenium test cases.
#
module SPEC_HELPER

  # The real driver to selenum
  attr_reader :selenium_driver
  # Nice little name
  alias :page :selenium_driver

  # Access the the loaded settings file.
  attr_accessor  :settings

  #
  # Shutdown and disconnect from the browser.
  #
  def end_browser_session
    @selenium_driver.close_current_browser_session
  end

  #
  # The settings file is loaded here.
  #
  def load_settings(file =  File.dirname(__FILE__) + "/../../config/settings.yml")
    @settings =  YAML::load(  File.open( file ))
    @settings
  end

  #
  # Inject the kobj static runtime script into the page.   Allow the url to be overridden with an
  # environment variable call kobj_static_url
  #
  def insert_runtime_script(r_ids, kobj_static_js_url = ENV["kobj_static_url"])

    if !kobj_static_js_url
      kobj_static_js_url = @settings["test"]["kobj_static_js_url"]
    end

    eval_host = ENV["eval_host"] 
    callback_host =ENV["callback_host"]
    init_host = ENV["init_host"]


    puts "Inserting Kobj Static JS : #{kobj_static_js_url} with rid's of #{r_ids.to_json}" 

    extra_init_info = ""

    extra_init_info = ', "init"  : {"eval_host" : "' +  eval_host +
             '", "callback_host":" ' + callback_host +
             '", "init_host" : "' + init_host + '"}' if eval_host

    if(!extra_init_info != "")
      puts "Using extra init params of " + extra_init_info
    end

    script = <<-ENDS
        var d = window.document;
        var r = d.createElement('script');
        r.text = 'KOBJ_config={"rids":#{r_ids.to_json} #{extra_init_info}};';
        var body = d.getElementsByTagName('body')[0];
        body.appendChild(r);
        var q = d.createElement('script');
        q.src = '#{kobj_static_js_url}';
        body.appendChild(q);
    ENDS

    puts "Injecting script: " + script
    
    page.js_eval(script)
  end

  #
  # Inject the kobj static runtime script into the page.   Allow the url to be overridden with an
  # environment variable call kobj_static_url
  #
  def insert_runtime_script_no_app(kobj_static_js_url = ENV["kobj_static_url"])

    if !kobj_static_js_url
      kobj_static_js_url = @settings["test"]["kobj_static_js_url"]
    end

    eval_host = ENV["eval_host"]
    callback_host =ENV["callback_host"]
    init_host = ENV["init_host"]


    puts "Inserting Kobj Static JS : #{kobj_static_js_url}"

    extra_init_info = {}
    extra_init_info =  {:eval_host =>  eval_host , :callback_host => callback_host,
        :init_host =>  init_host } if eval_host


    script = <<-ENDS
        var d = window.document;
        var body = d.getElementsByTagName('body')[0];
        var q = d.createElement('script');
        q.src = '#{kobj_static_js_url}';
        body.appendChild(q);
    ENDS

    puts "Injecting script: " + script

    page.js_eval(script)

#    page.wait_for({:wait_for => :condition , :timeout_in_seconds => 30, :javascript => "typeof(window.KOBJ) != 'undefined'"});
    page.wait_for({:wait_for => :condition , :javascript => "typeof(window.KOBJ) != 'undefined'"});

    page.js_eval("window.KOBJ.configure_kynetx(#{extra_init_info.to_json})")


  end





  #
  # Create a new browser session using the information from the settings file.  This will also open the requested
  # page.
  #
  def start_browser_session(settings,domain, url, timeout = 30)
    @selenium_driver = Selenium::Client::Driver.new(
            :host => settings[ENV["browser"]]["host"],
            :port => settings[ENV["browser"]]["port"],
            :browser => settings[ENV["browser"]]["browser"],
            :url => domain,
            :timeout_in_second => settings[ENV["browser"]]["timeout"] || timeout)
    @selenium_driver.start_new_browser_session
    puts "Connecting browser to url : #{domain}#{url}"
    @selenium_driver.open(url)
  end

end