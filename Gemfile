# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

gem 'i18n'

group :development do
  gem 'fasterer'
  gem 'pry'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'overcommit'
end

group :test do
  gem "rspec", "~> 3.8"
  gem 'simplecov'
  gem 'simplecov-lcov'
  gem 'undercover'
  gem 'rugged', ">=0.26.0"
end
