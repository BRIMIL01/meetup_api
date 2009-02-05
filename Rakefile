require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'

task :default => :test

spec = Gem::Specification.new do |s|
  s.name             = 'meetup_api'
  s.version          = '0.1.0'
  s.has_rdoc         = true
  s.extra_rdoc_files = %w(README)
  s.rdoc_options     = %w(--main README)
  s.summary          = "Ruby port of Meetup's official Python API client"
  s.author           = 'Bosco So'
  s.email            = 'git@boscoso.com'
  s.homepage         = 'http://boscoso.com'
  s.files            = %w(README Rakefile) + Dir.glob("{lib,test}/**/*")
  
  s.add_dependency('json', '= 1.1.3')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

desc 'Generate the gemspec to serve this Gem from Github'
task :github do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, 'w') {|f| f << spec.to_ruby }
  puts "Created gemspec: #{file}"
end