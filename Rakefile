require 'rubygems'
require 'rake'
require 'rake/rdoctask'

desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'vihai-assert2'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README', 'NOTICE')
  rdoc.rdoc_files.include('lib/assert2.rb')
  rdoc.rdoc_files.include('lib/assert2/**/*.rb')
end


begin
  require 'jeweler'

  Jeweler::Tasks.new do |s|
    s.name = 'vihai-assert2'
    s.summary = 'rspec expectations for XML/HTML'
    s.email = 'daniele@orlandi.com'
    s.homepage = 'http://www.orlandi.com/'
    s.description = 'rspec expectations for XML/HTML'
    s.authors = ['Daniele Orlandi']
    s.files = FileList['[A-Z]*.*', '{lib}/**/*', 'VERSION']
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org'
end
