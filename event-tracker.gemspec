# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'event_tracker/version'

Gem::Specification.new do |s|
  s.name        = 'event-tracker'
  s.version     = EventTracker::VERSION
  s.summary     = 'Quick and easy tracking of server-side and client side events for Rails'
  s.description = 'This library allows the easy implementation of server-side and client side tracking of various events.'
  s.authors     = ['Donald Piret']
  s.email       = 'donald@donaldpiret.com'
  s.homepage    = 'https://github.com/donaldpiret/event-tracker'
  s.license     = 'MIT'

  s.files            = %w(LICENSE README.md) + Dir['lib/**/*.rb'] + Dir['lib/**/*.sh'] + Dir['bin/*']
  s.executables      = Dir['bin/*'].map { |f| File.basename f }
  s.test_files       = Dir['spec/**/*_spec.rb']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'analytics-ruby', '~> 2.0.6'
  s.add_dependency 'activesupport'
  s.add_dependency 'rails', '>= 3.0.0', '<= 5.0.0'

  s.add_development_dependency 'bundler', '~> 1.3'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0.2'
  s.add_development_dependency 'sqlite3'
end