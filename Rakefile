# encoding: utf-8
# -*- encoding: utf-8 -*-
# -*- ruby -*-


lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :default => :test

require 'rdoc/task'
RDoc::Task.new do |rdoc|

  vfile = File.new("VERSION", "r")
  version = vfile.gets

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gmail_xoauth #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rubygems'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "ruby_gmail_xoauth"
    gem.summary = %Q{A Rubyesque interface to Gmail, with all the tools you'll need.}
    gem.description = %Q{A Rubyesque interface to Gmail, with all the tools you'll need. Search, read and send multipart emails; archive, mark as read/unread, delete emails; and manage labels.}
    gem.email = "chris.duesing@gmail.com"
    gem.homepage = "https://github.com/chrisduesing/ruby_gmail_xoauth"
    gem.authors = [ "Chris Duesing", "BehindLogic", "Nicolas Fouché" ]
    gem.add_dependency('shared-mime-info', '>= 0')
    gem.add_dependency('mail', '>= 2.2.1')
    gem.add_dependency('mime', '>= 0.1')
    gem.add_dependency "oauth", ">= 0.3.6"
    gem.add_development_dependency "shoulda", ">= 0"
    gem.files.include Dir.glob("{bin,lib,test}/**/*") + %w(LICENSE README.markdown)
    gem.files.exclude { |fn| fn.include? "valid_credentials.yml" }
    gem.require_path = 'lib'
    gem.rdoc_options = ["--charset=UTF-8"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end
