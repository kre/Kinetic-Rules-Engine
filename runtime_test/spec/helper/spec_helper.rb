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

    script = <<-ENDS
        var d = window.document;
        var r = d.createElement('script');
        r.text = 'KOBJ_config ={    "rids"  : #{r_ids.to_json},"init"  : {"eval_host" : "qa.kobj.net", "callback_host":"qa.kobj.net", "init_host" : "qa.kobj.net"}};';
        var body = d.getElementsByTagName('body')[0];
        body.appendChild(r);
        var q = d.createElement('script');
        q.src = '#{kobj_static_js_url}';
        body.appendChild(q);
    ENDS

    
    page.js_eval(script)
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
            :timeout_in_second => timeout)
    @selenium_driver.start_new_browser_session
    @selenium_driver.open(url)
  end

end