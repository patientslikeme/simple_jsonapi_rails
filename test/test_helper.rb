$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# Set up the dummy app
ENV['RAILS_ENV'] = 'test'
require_relative 'dummy/config/environment'
ActiveRecord::Migrator.migrate File.expand_path("dummy/db/migrate/", __dir__)

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
require 'pry'
require 'pp'

require 'simple_jsonapi/rails'
require 'simple_jsonapi/rails/test_helpers'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  self.test_order = :random

  include ActiveRecord::TestFixtures
  self.use_transactional_tests = true
end
