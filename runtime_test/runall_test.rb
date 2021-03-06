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
  
  if !ENV['kobj_static_url'] 
  	puts "Using default kobj_static_url : " + settings["test"]["kobj_static_js_url"]
  end
  
  settings['test']['testing_servers'].each do |browser|
    ENV['browser'] = browser
    puts "Testing Browser " + browser
    STDOUT.flush
    cmd = "rake browser_test 2>&1"
    result = %x[#{cmd}]
    code = $?
    puts result

    if code == 0
      matcher = /(\d+) failures/.match(result)

      # if we have failures
      if matcher[0].to_i != 0
        code = matcher[0].to_i
      end

    end
    STDOUT.flush
    if code != 0
      puts "Error runing rake task for #{browser}"
      bad_code = code
    end
  end
else

  cmd = "rake browser_test 2>&1"
  result = %x[#{cmd}]
  code = $?
  puts result

  if code == 0
    matcher = /(\d+) failures/.match(result)

    # if we have failures
    if matcher[0].to_i != 0
      code = matcher[0].to_i
    end
  end

end

STDOUT.flush
puts "Existing Process with code : #{bad_code}"
exit(bad_code)
