# frozen_string_literal: true
source 'https://rubygems.org'

gemspec

gem 'active_flow', github: 'shun159/active_flow', branch: 'feature/ovsdb/core'

group :guard do
  gem 'guard', require: false
  gem 'guard-bundler', require: false
  gem 'guard-cucumber', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  # To support Ruby 2.1; Listen 3.1.0 or later does not run on Ruby 2.1
  gem 'listen', '< 3.1.0'
end

group :test do
  gem 'aruba', require: false
  gem 'cucumber', require: false
  gem 'faker', require: false
  gem 'rake', require: false
  gem 'rspec', require: false
  gem 'rspec-given', require: false
end

group :metrics do
  gem 'codeclimate-test-reporter', require: false
  gem 'coveralls', require: false
  gem 'flay', require: false
  gem 'flog', require: false
  gem 'reek', require: false
  gem 'rubocop', require: false
end

group :doc do
  gem 'relish', require: false
  gem 'yard', require: false
end
