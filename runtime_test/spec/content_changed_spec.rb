require File.dirname(__FILE__) + "/helper/spec_helper.rb"


#
# Test Search engine annotation rules.
#
describe "Content Change Event Test" do
  include SPEC_HELPER

  before(:all) do
    load_settings
  end


  describe "Content Changes on Simple PAge" do

    before(:each) do
      start_browser_session(@settings, "http://k-misc.s3.amazonaws.com", "/runtime-dependencies/content_change_test.html")
    end

    after(:each) do
      end_browser_session
    end

    #
    # The rule basicly add phone numbers to the search page and we need to find them
    #
    it "should insert test in divs that say page changed" do
      insert_runtime_script(["a685x10"])
      page.wait_for({:wait_for => :element,  :element => "//div[@id='fired']"});
      sleep(5)
      page.js_eval( "window.$KOBJ('#other_changed').append('data')")      
      page.wait_for_condition("window.$KOBJ('#change_result').text().strip() == 'second_rule_fired'",60);
      page.wait_for_condition("window.$KOBJ('#change_result2').text().strip() == 'third_rule_fired'",30);
      
    end

  end


end
