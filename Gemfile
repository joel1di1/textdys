# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.5'

gem 'bootsnap', require: false
gem 'importmap-rails'
gem 'jbuilder'
gem 'puma'
gem 'ruby-progressbar'
gem 'rails', '~> 8.0.2'
gem 'slim'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'turbo-rails'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mswin mswin64 mingw x64_mingw]
  gem 'rspec-rails', '~> 8.0.1'
end

group :development do
  gem 'error_highlight', '>= 0.4.0', platforms: [:ruby]
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end
