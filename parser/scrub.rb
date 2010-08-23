require "rubygems"

if (!File.exist?(ARGV[0]))
  exit(1);
end
leftside = ""

File.open(ARGV[0]).each_line { |s|
  leftside << s
}

if leftside.size == 0 || leftside.size == 14
  puts "Removing " + ARGV[0]
  File.delete(ARGV[0])
end
puts "Done " + ARGV[0]




