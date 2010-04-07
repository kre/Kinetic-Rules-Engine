require 'spec/helper/spec_helper'

include SPEC_HELPER

if ENV['browser']
  puts  "Browser override set to: #{ENV['browser']}"
end

if ENV['kobj_static_url']
  puts  "URL override set to: #{ENV['kobj_static_url']}"
end

if !ENV['browser']
  puts "All Browser begin tested"
  settings = load_settings(File.dirname(__FILE__) + "/config/settings.yml")
  settings['test']['testing_servers'].each do |browser|
    ENV['browser'] = browser
    cmd = "rake browser_test 2>&1"
    result = %x[#{cmd}]
    code = $?
    puts result
    if code != 0
      puts "Error runing rake task for #{browser}"
      exit(5);
    end
  end
else

  cmd = "rake browser_test 2>&1"
  result = %x[#{cmd}]
  code = $?
  puts result
  if code != 0
    puts "Error runing rake task for #{browser}"
    exit(5);
  end
end