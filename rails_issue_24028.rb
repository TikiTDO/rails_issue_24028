begin
  require 'bundler/inline'
rescue LoadError => e
  $stderr.puts 'Bundler version 1.10 or later is required. Please update your Bundler'
  raise e
end

gemfile(true) do
  source 'https://rubygems.org'
  # Activate the gem you are reporting the issue against.
  #gem 'rails', git: 'https://github.com/rails/rails'
  gem 'rails', path: '/home/tiki/rails'
  gem 'pry'
  gem 'pry-stack_explorer'
  gem 'pry-byebug'
  #gem 'ruby-prof'
  #gem 'memory_profiler'
end

require 'rack/test'
require 'action_controller/railtie'
require 'active_support/railtie'

class TestApp < Rails::Application
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: 'cookie_store_key'
  secrets.secret_token    = 'secret_token'
  secrets.secret_key_base = 'secret_key_base'

  ActiveSupport::Dependencies.autoload_paths << Rails.root
  config.cache_classes = false

  config.logger = Logger.new($stdout)
  Rails.logger  = config.logger

  routes.draw do
    root to: 'test#index'
  end
end

class TestController < ActionController::Base
  include Rails.application.routes.url_helpers

  def index
    puts "Index"

    Thread.new do
      puts "Started thread to load A"
      AutoloadA
    end.join
    puts "Done Loading"
    render plain: ''
  end
end

require 'minitest/autorun'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

class BugTest < Minitest::Test
  include Rack::Test::Methods

  def test_returns_success
    waiter = Thread.new do
      while true
        sleep(1.0)
        binding.pry
        puts "Deadlock in Interlock..."
      end
    end
    get '/'
    waiter.kill
  end

  private
    def app
      Rails.application
    end
end
