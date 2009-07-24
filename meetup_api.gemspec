# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{meetup_api}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bosco So"]
  s.date = %q{2009-02-04}
  s.email = %q{user@example.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "Rakefile", "lib/meetup_api.rb", "test/api_key.README", "test/meetup_api_tester.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://example.com}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby port of Meetup's official Python API client}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, ["= 1.1.3"])
    else
      s.add_dependency(%q<json>, ["= 1.1.3"])
    end
  else
    s.add_dependency(%q<json>, ["= 1.1.3"])
  end
end
