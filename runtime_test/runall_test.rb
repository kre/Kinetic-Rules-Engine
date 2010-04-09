require 'spec/helper/spec_helper'

include SPEC_HELPER

if ENV['browser']
  puts  "Browser override set to: #{ENV['browser']}"
end

if ENV['kobj_static_url']
  puts  "URL override set to: #{ENV['kobj_static_url']}"
end

STDOUT.flush
bad_code = 0

if !ENV['browser']
  puts "All Browser begin tested"
  settings = load_settings(File.dirname(__FILE__) + "/config/settings.yml")
  settings['test']['testing_servers'].each do |browser|
    ENV['browser'] = browser
    puts "Testing Browser " + browser
    STDOUT.flush
    cmd = "rake browser_test 2>&1"
    result = %x[#{cmd}]
    code = $?
    puts result
    STDOUT.flush
    if code != 0
      puts "Error runing rake task for #{browser}"
      bad_code = code
    end
  end
  if bad_code
    exit(bad_code)
  end
else

  cmd = "rake browser_test 2>&1"
  result = %x[#{cmd}]
  code = $?
  puts result
  STDOUT.flush
  if code != 0
    puts "Error runing rake task for #{browser}"
    exit(5);
  end
end