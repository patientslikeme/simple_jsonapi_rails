require 'rails/railtie'

module SimpleJsonapi
  module Rails
    class Railtie < ::Rails::Railtie
      initializer 'simple_jsonapi_rails.initialize' do
        Mime::Type.register(SimpleJsonapi::MIME_TYPE, :jsonapi)

        ActiveSupport.on_load(:action_controller) do
          ::ActionDispatch::Request.parameter_parsers[:jsonapi] = ->(raw_post) do
            ActiveSupport::JSON.decode(raw_post)
          end

          # In the renderers, `self` is the controller

          ::ActionController::Renderers.add(:jsonapi_resource) do |resource, options|
            if respond_to?(:media_type)
              self.content_type = Mime[:jsonapi] unless self.media_type
            else
              self.content_type ||= Mime[:jsonapi]
            end

            SimpleJsonapi.render_resource(resource, options).to_json
          end

          ::ActionController::Renderers.add(:jsonapi_resources) do |resources, options|
            if respond_to?(:media_type)
              self.content_type = Mime[:jsonapi] unless self.media_type
            else
              self.content_type ||= Mime[:jsonapi]
            end

            SimpleJsonapi.render_resources(resources, options).to_json
          end

          ::ActionController::Renderers.add(:jsonapi_errors) do |errors, options|
            if respond_to?(:media_type)
              self.content_type = Mime[:jsonapi] unless self.media_type
            else
              self.content_type ||= Mime[:jsonapi]
            end

            SimpleJsonapi.render_errors(errors, options).to_json
          end
        end
      end
    end
  end
end
