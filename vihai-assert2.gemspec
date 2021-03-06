# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{vihai-assert2}
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniele Orlandi"]
  s.date = %q{2010-11-16}
  s.description = %q{rspec expectations for XML/HTML}
  s.email = %q{daniele@orlandi.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "VERSION",
    "lib/assert2.rb",
    "lib/assert2/flunk.rb",
    "lib/assert2/ripdoc.html.erb",
    "lib/assert2/ripdoc.rb",
    "lib/assert2/ripper_reflector.rb",
    "lib/assert2/rjs.rb",
    "lib/assert2/rubynode_reflector.rb",
    "lib/assert2/xhtml.rb",
    "lib/assert2/xpath.rb"
  ]
  s.homepage = %q{http://www.orlandi.com/}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{rspec expectations for XML/HTML}
  s.test_files = [
    "test/assert2_rjs_spec.rb",
    "test/assert2_rjs_suite.rb",
    "test/assert2_spec.rb",
    "test/assert2_suite.rb",
    "test/assert2_utilities_suite.rb",
    "test/assert2_xhtml_suite.rb",
    "test/assert2_xpath_suite.rb",
    "test/ripdoc_suite.rb",
    "test/ripper_reflector_suite.rb",
    "test/rubynode_reflector_suite.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

