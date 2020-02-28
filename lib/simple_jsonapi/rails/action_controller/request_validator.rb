module SimpleJsonapi
  module Rails
    module ActionController
      class RequestValidator
        attr_reader :request, :params

        delegate :body, :content_type, :media_type, :accept, :path, to: :request, prefix: true

        def initialize(request, params)
          @request = request
          @params = params
        end

        def valid_content_type_header?
          if request.respond_to?(:media_type)
            !request_has_body? || request_media_type == SimpleJsonapi::MIME_TYPE
          else
            !request_has_body? || request_content_type == SimpleJsonapi::MIME_TYPE
          end
        end

        def valid_accept_header?
          request_accept.blank? || request_accept == SimpleJsonapi::MIME_TYPE
        end

        def valid_request_body?
          return true unless request_has_body?

          params["data"].present? && valid_relationship_body?
        end

        def valid_relationship_body?
          request_path.exclude?("relationships") || params["data"]&.is_a?(Array)
        end

        private

        def request_has_body?
          request_body.size > 0
        end
      end
    end
  end
end
