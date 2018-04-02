require 'active_support'

require 'simple_jsonapi'

require 'simple_jsonapi/rails/extensions'
require 'simple_jsonapi/rails/extensions/routing'
require 'simple_jsonapi/rails/action_controller'
require 'simple_jsonapi/rails/action_controller/jsonapi_helper'
require 'simple_jsonapi/rails/railtie'

require 'simple_jsonapi/errors/active_record/record_not_found_serializer'
require 'simple_jsonapi/errors/active_model_error'
require 'simple_jsonapi/errors/active_model_error_serializer'
