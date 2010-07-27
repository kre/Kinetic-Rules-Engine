#!/usr/bin/ruby
# == Synopsis
#
# Sends files in frameworks directory to S3 and sets types and permissions.
#
# == Usage
#
# install-js-resources [OPTION]
#
# -h, --help:
#    show help
#
# -f framework_name:
#    Send only this framework to s3
#
# -v framework_version:
#    Send only this version of the provided framework to s3
#
# -a send everything:
#    Send all the frameworks and version to s3
#
# -d dry run:
#    Do not perform any action just print what will happen.
#

require 'rubygems'
require 'getoptlong'
require 'rdoc/usage'
require 'net/http'
require 'aws/s3'
require 'pp'

#
# Reads the s3 data store for frameworks and turns the data in to
# a has of s3 object that can be used to find the files later
#
def list_s3_frameworks()
  framework_bucket = AWS::S3::Bucket.find('kns-resources')
  temp = framework_bucket.objects()

  result = {}
  temp.collect { |s3object| result[s3object.key]  = s3object }
  return result
end

#
# Get a list of files in our local frameworks directory
#
def frameworks_file_list(directory)
  files = File.join(FRAMEWORKS_ROOT_DIR + directory, "**", "**", "*")
  list = Dir.glob(files)

  result = list.collect { |entry| entry[(FRAMEWORKS_ROOT_DIR.length + 1)..9999] }
  return result
end


opts = GetoptLong.new(
        ['--help', '-h', GetoptLong::NO_ARGUMENT],
        ['-f', GetoptLong::OPTIONAL_ARGUMENT],
        ['-v', GetoptLong::OPTIONAL_ARGUMENT],
        ['-d', GetoptLong::OPTIONAL_ARGUMENT],
        ['-a', GetoptLong::NO_ARGUMENT]
)

framework = nil
version = nil
all_frameworks = nil;
dry_run = false;

FRAMEWORKS_ROOT_DIR = File.dirname(__FILE__) + "/../etc/js/0.9/frameworks"

opts.each do |opt, arg|
  case opt
    when '--help'
      RDoc::usage
    when '-f'
      framework = arg
    when '-v'
      version = arg
    when '-d'
      puts "********  Running in Dry run mode no changes will happen *************"
      dry_run = true;
    when '-a'
      all_frameworks = "yes"
  end
end

if !framework && !version && !all_frameworks
  puts "Missing argument (try --help)"
  exit 5
end

# Create the connection to S3
AWS::S3::Base.establish_connection!(
        :access_key_id     => '0GEYA8DTVCB3XHM819R2',
        :secret_access_key => 'I4TrjKcflLnchhsEzjlNju/s9EHiqdOScbyqGgn+'
)

# Compute what our local framework directory
path = "/"
if framework
  path = path + framework
end

if version
  path = path + "/" + version
end


files_to_process = frameworks_file_list(path)
current_s3_framework_files = list_s3_frameworks

# Search for all the files we have on our local system and either
# replace or upload new one.
files_to_process.each do |file_or_dir|
  if !File.directory?(FRAMEWORKS_ROOT_DIR + "/" +file_or_dir)
    if (!current_s3_framework_files[file_or_dir])
      puts "Adding file #{file_or_dir}"
    else
      puts "Updating file #{file_or_dir}"
    end
    if (!dry_run)
      AWS::S3::S3Object.store( file_or_dir,
                              open(FRAMEWORKS_ROOT_DIR + "/" +file_or_dir),
                              'kns-resources',
                              :access => :public_read)
    end
  end
end






