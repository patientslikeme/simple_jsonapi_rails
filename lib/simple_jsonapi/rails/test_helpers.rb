# SimpleJsonapi::Rails::Railtie.initializers.each(&:run)

# Work-around for rack-test/rack-test#200, which is resolved in rack-test 1.0.0 (see rack-test/rack-test#223)
if Gem::Version.new(Rack::Test::VERSION) < Gem::Version.new("1.0.0")
  module PatchRackTestDeleteRequests
    def request(uri, env = {}, &block)
      if env[:method] == :delete && env["HTTP_ACCEPT"] == SimpleJsonapi::MIME_TYPE && env[:params].present?
        env[:input] = env[:params]
      end

      super(uri, env, &block)
    end
  end

  Rack::Test::Session.prepend(PatchRackTestDeleteRequests)
end

ActiveSupport.on_load(:action_controller) do
  ActionDispatch::IntegrationTest.register_encoder :jsonapi,
    param_encoder:   ->(params) { params&.to_json },
    response_parser: ->(body) { JSON.parse(body) if body.present? }
end
