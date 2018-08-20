require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults 5.1

    if Gem::Version.new(Rails.version) >= Gem::Version.new("5.2.0")
      Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true
    end
  end
end
