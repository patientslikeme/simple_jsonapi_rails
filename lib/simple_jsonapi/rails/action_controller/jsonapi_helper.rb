require 'simple_jsonapi/rails/action_controller/request_validator'

module SimpleJsonapi
  module Rails
    module ActionController
      class JsonapiHelper
        attr_reader :controller, :pointers, :request_validator

        delegate :params, :render, :request, :head, to: :controller, allow_nil: true

        def initialize(controller)
          @controller = controller
          @pointers = {}
          @request_validator = RequestValidator.new(request, params)
        end

        def include_params
          params[:include].to_s.split(/,/).presence
        end

        def fields_params
          (params[:fields] || {}).transform_values { |f| f.split(/,/) }
        end

        def filter_param(param_name)
          (params[:filter] || {})[param_name]
        end

        def filter_param_list(param_name)
          param_value = filter_param(param_name)
          return nil unless param_value

          param_value.split(/,/)
        end

        def sort_related_params
          (params[:sort_related] || {}).transform_values { |f| f.split(/,/) }
        end

        # @param error [ActiveRecord::RecordNotFound]
        def render_record_not_found(error)
          render jsonapi_errors: error, status: :not_found
        end

        def render_model_errors(model)
          errors = SimpleJsonapi::Errors::ActiveModelError.from_errors(model.errors, pointers)
          render jsonapi_errors: errors, status: :unprocessable_entity
        end

        def render_bad_request(message)
          error = SimpleJsonapi::Errors::BadRequest.new(detail: message)
          render jsonapi_errors: [error], status: :bad_request
        end

        # private

        # def url_helpers
        #   ::Rails.application.routes.url_helpers
        # end

        def deserialize(jsonapi_data)
          jsonapi_hash = case jsonapi_data
          when String then JSON.parse(jsonapi_data).deep_symbolize_keys
          when Hash then jsonapi_data.deep_symbolize_keys
          else jsonapi_data
          end

          data = jsonapi_hash[:data]
          return unless data

          result = {}
          pointers = {}

          result[:type] = data[:type]
          result[:id] = data[:id]
          pointers[:type] = "/data/type"
          pointers[:id] = "/data/id"

          if data[:attributes].present?
            data[:attributes].each do |name, value|
              result[name] = value
              pointers[name] = "/data/attributes/#{name}"
            end
          end

          if data[:relationships].present?
            data[:relationships].each do |name, value|
              related_data = value[:data]

              if related_data.is_a?(Array)
                singular_name = name.to_s.singularize
                result[:"#{singular_name}_types"] = related_data.pluck(:type)
                result[:"#{singular_name}_ids"] = related_data.pluck(:id)
                pointers[:"#{singular_name}_types"] = "/data/relationships/#{name}"
                pointers[:"#{name}_ids"] = "/data/relationships/#{name}"
              elsif related_data.is_a?(Hash)
                result[:"#{name}_type"] = related_data[:type]
                result[:"#{name}_id"] = related_data[:id]
                pointers[:"#{name}_type"] = "/data/relationships/#{name}"
                pointers[:"#{name}_id"] = "/data/relationships/#{name}"
              end
            end
          end

          @pointers = pointers
          result
        end

        def validate_jsonapi_request_headers
          return head :unsupported_media_type unless request_validator.valid_content_type_header?
          head :not_acceptable unless request_validator.valid_accept_header?
        end

        def validate_jsonapi_request_body
          unless request_validator.valid_request_body?
            raise InvalidJsonStructureError, "Not a valid jsonapi request body"
          end
        end
      end
    end
  end
end
