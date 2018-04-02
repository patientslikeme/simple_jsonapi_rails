module SimpleJsonapi
  module Rails
    module ActionController
      extend ActiveSupport::Concern

      delegate :validate_jsonapi_request_headers, :validate_jsonapi_request_body, to: :jsonapi

      included do
        before_action :validate_jsonapi_request_headers
        before_action :validate_jsonapi_request_body

        rescue_from ActiveRecord::RecordNotFound do |err|
          jsonapi.render_record_not_found(err)
        end

        rescue_from ActiveRecord::RecordInvalid do |err|
          jsonapi.render_model_errors(err.record)
        end

        rescue_from ActiveRecord::RecordNotSaved do |err|
          jsonapi.render_model_errors(err.model)
        end

        rescue_from InvalidJsonStructureError do |err|
          jsonapi.render_bad_request(err.message)
        end
      end

      class_methods do
        def jsonapi_deserialize(param_key, options = {})
          prepend_before_action(options) do
            if request.raw_post.present?
              params[param_key] = jsonapi.deserialize(request.request_parameters)
            end
          end
        end
      end

      def jsonapi
        @jsonapi ||= SimpleJsonapi::Rails::ActionController::JsonapiHelper.new(self)
      end
    end
  end
end
