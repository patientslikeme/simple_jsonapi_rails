$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

# Set up the dummy app
ENV['RAILS_ENV'] = 'test'
require_relative 'dummy/config/environment'
# change to ActiveRecord::MigrationContext.new(File.expand_path("dummy/db/migrate/", __dir__)).migrate
# when we upgrade rails >= 5.2.0
ActiveRecord::Migrator.migrate File.expand_path("dummy/db/migrate/", __dir__)

require 'active_support'

require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/reporters'
require 'pry'
require 'pp'

require 'simple_jsonapi/rails'
require 'simple_jsonapi/rails/test_helpers'

if ENV['BUILD_NUMBER']
  Minitest::Reporters.use!(
    [MiniTest::Reporters::DefaultReporter.new, MiniTest::Reporters::JUnitReporter.new('test/reports')],
    ENV,
    Minitest.backtrace_filter,
  )
else
  Minitest::Reporters.use!(Minitest::Reporters::SpecReporter.new, ENV, Minitest.backtrace_filter)
end

class ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  self.test_order = :random

  include ActiveRecord::TestFixtures
  self.use_transactional_tests = true
end
