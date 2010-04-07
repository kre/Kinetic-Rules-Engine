# == Synopsis
#
# submit_test - Sents test to remote testing server.
#
# == Usage
#
# hello [OPTION]
#
# -h, --help:
#    show help
#
# -u username:
#    your team city user name
#
# -p password:
#    your team city user name
#
# -b browser_to_test:
#    current support are -
#     firefox_30_osx , safari_30_osx, ie6_windows, ie7_windows, ie8_windows, chrome_beta_windows , chrome_beta_osx, chrome_beta_linux
#
# -t:
#    move your job to top of queue
#
# -url url_of_kobj:
#    full url of the kobj java script to test.
#
#
#

require 'getoptlong'
require 'rdoc/usage'
require 'net/http'

opts = GetoptLong.new(
        [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
        [ '-u', GetoptLong::REQUIRED_ARGUMENT ],
        [ '-p', GetoptLong::REQUIRED_ARGUMENT ],
        [ '-b', GetoptLong::OPTIONAL_ARGUMENT ],
        [ '-t', GetoptLong::NO_ARGUMENT ],
        [ '-k', GetoptLong::OPTIONAL_ARGUMENT ]

)

user = nil
password = nil
top = false;
url = nil
browser = nil


opts.each do |opt, arg|
  case opt
    when '--help'
      RDoc::usage
    when '-u'
      user = arg
    when '-t'
      top = true
    when '-p'
      password = arg
    when '-k'
      url = arg
    when '-b'
      browser = arg
  end
end

if !user || !password
  puts "Missing dir argument (try --help)"
  exit 0
end
#cmd = "wget http://#{user}:#{password}@webhost.kynetx.com:8111/httpAuth/action.html?add2Queue=bt3"
cmd = ""
if top
  cmd = cmd + "&moveToTop=true"
end

if url
  cmd = cmd + "&env.name=kobj_static_url&env.value=#{url}"
end

if browser
  cmd = cmd + "&env.name=browser&env.value=#{browser}"
end


Net::HTTP.start('webhost.kynetx.com',8111) {|http|
  req = Net::HTTP::Get.new("/httpAuth/action.html?add2Queue=bt3#{cmd}")
  req.basic_auth user, password
  response = http.request(req)
  print response.body
}

puts "Submitted Job to Testing System."
puts "URL : " + url if url
puts "BROWSER : " + browser if browser

