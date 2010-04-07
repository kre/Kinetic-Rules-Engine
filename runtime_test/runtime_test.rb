#!/usr/bin/env ruby

# Define a task library for running RSpec contexts.

require 'rake'
require 'rake/tasklib'
require 'spec/helper/spec_helper'

module RuntimeTest
  module Rake

    # A Rake task that runs a set of specs.
    #
    # Example:
    #
    #   Spec::Rake::SpecTask.new do |t|
    #     t.warning = true
    #     t.rcov = true
    #   end
    #
    # This will create a task that can be run with:
    #
    #   rake spec
    #
    # If rake is invoked with a "SPEC=filename" command line option,
    # then the list of spec files will be overridden to include only the
    # filename specified on the command line.  This provides an easy way
    # to run just one spec.
    #
    # If rake is invoked with a "SPEC_OPTS=options" command line option,
    # then the given options will override the value of the +spec_opts+
    # attribute.
    #
    #
    # Examples:
    #
    #   rake spec                                      # run specs normally
    #   rake spec SPEC=just_one_file.rb                # run just one spec file.
    #   rake spec SPEC_OPTS="--diff"                   # enable diffing
    #   rake spec RCOV_OPTS="--aggregate myfile.txt"   # see rcov --help for details
    #
    # Each attribute of this task may be a proc. This allows for lazy evaluation,
    # which is sometimes handy if you want to defer the evaluation of an attribute value
    # until the task is run (as opposed to when it is defined).
    #
    # This task can also be used to run existing Test::Unit tests and get RSpec
    # output, for example like this:
    #
    #   require 'spec/rake/spectask'
    #   Spec::Rake::SpecTask.new do |t|
    #     t.ruby_opts = ['-rtest/unit']
    #     t.spec_files = FileList['spec/**/*_test.rb']
    #   end
    #
    class SpecTask < ::Rake::TaskLib
      def self.attr_accessor(*names)
        super(*names)
        names.each do |name|
          module_eval "def #{name}() evaluate(@#{name}) end" # Allows use of procs
        end
      end

      # Name of spec task. (default is :spec)
      attr_accessor :name

      # Array of directories to be added to $LOAD_PATH before running the
      # specs. Defaults to ['<the absolute path to RSpec's lib directory>']
      attr_accessor :libs

      # If true, requests that the specs be run with the warning flag set.
      # E.g. warning=true implies "ruby -w" used to run the specs. Defaults to false.
      attr_accessor :warning

      # Glob pattern to match spec files. (default is 'spec/**/*_spec.rb')
      # Setting the SPEC environment variable overrides this.
      attr_accessor :pattern

      # Array of commandline options to pass to RSpec. Defaults to [].
      # Setting the SPEC_OPTS environment variable overrides this.
      attr_accessor :spec_opts

      # Array of commandline options to pass to ruby. Defaults to [].
      attr_accessor :ruby_opts

      # Whether or not to fail Rake when an error occurs (typically when specs fail).
      # Defaults to true.
      attr_accessor :fail_on_error

      # A message to print to stderr when there are failures.
      attr_accessor :failure_message


      # Explicitly define the list of spec files to be included in a
      # spec.  +spec_files+ is expected to be an array of file names (a
      # FileList is acceptable).  If both +pattern+ and +spec_files+ are
      # used, then the list of spec files is the union of the two.
      # Setting the SPEC environment variable overrides this.
      attr_accessor :spec_files

      # Use verbose output. If this is set to true, the task will print
      # the executed spec command to stdout. Defaults to false.
      attr_accessor :verbose

      # Explicitly define the path to the ruby binary, or its proxy (e.g. multiruby)
      attr_accessor :ruby_cmd

      # Defines a new task, using the name +name+.
      def initialize(name=:spec)
        @name = name
        @libs = ['lib']
        @pattern = nil
        @spec_files = nil
        @spec_opts = []
        @warning = false
        @ruby_opts = []
        @fail_on_error = true

        yield self if block_given?
        @pattern = 'spec/**/*_spec.rb' if pattern.nil? && spec_files.nil?
        define
      end

      include SPEC_HELPER

      def define # :nodoc:
#        spec_script = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "bin", "spec"))
        spec_script = "/usr/bin/spec"

        lib_path = libs.join(File::PATH_SEPARATOR)
        actual_name = Hash === name ? name.keys.first : name
        task name do
          RakeFileUtils.verbose(verbose) do
            unless spec_file_list.empty?
              # ruby [ruby_opts] -Ilib -S rcov [rcov_opts] bin/spec -- examples [spec_opts]
              # or
              # ruby [ruby_opts] -Ilib bin/spec examples [spec_opts]
              cmd_parts = [ruby_cmd || RUBY]
              cmd_parts += ruby_opts
              cmd_parts << %[-I"#{lib_path}"]
              cmd_parts << "-w" if warning
              cmd_parts << %["#{spec_script}"]
              cmd_parts += spec_file_list.collect { |fn| %["#{fn}"] }
              cmd_parts << spec_option_list
              cmd = cmd_parts.join(" ")
              settings = load_settings(File.dirname(__FILE__) + "/config/settings.yml")
              settings["test"]["testing_servers"].each do |browser|
                puts "Testing for browser " + browser
                ENV['browser'] = browser
                ENV["SELENIUM_TEST_REPORT_FILE"] = "./report/#{browser}/#{browser}_tests_report.html"
#                cmd = cmd + " --format=Selenium::RSpec::SeleniumTestReportFormatter:./report/#{browser}/#{browser}_tests_report.html"
                puts cmd if verbose
                unless system(cmd)
                  STDERR.puts failure_message if failure_message
                  raise("Command #{cmd} failed") if fail_on_error
                end
              end
            end
          end
        end

        self
      end


      def spec_option_list # :nodoc:
        STDERR.puts "RSPECOPTS is DEPRECATED and will be removed in a future version. Use SPEC_OPTS instead." if ENV['RSPECOPTS']
        ENV['SPEC_OPTS'] || ENV['RSPECOPTS'] || spec_opts.join(" ") || ""
      end

      def evaluate(o) # :nodoc:
        case o
          when Proc then
            o.call
          else
            o
        end
      end

      def spec_file_list # :nodoc:
        if ENV['SPEC']
          FileList[ ENV['SPEC'] ]
        else
          result = []
          result += spec_files.to_a if spec_files
          result += FileList[ pattern ].to_a if pattern
          FileList[result]
        end
      end

    end
  end
end
