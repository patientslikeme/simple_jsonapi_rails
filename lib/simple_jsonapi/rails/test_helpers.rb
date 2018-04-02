# SimpleJsonapi::Rails::Railtie.initializers.each(&:run)

# Work-around for rack-test/rack-test#200. Remove once that issue is resolved.
module PatchRackTestDeleteRequests
  def request(uri, env = {}, &block)
    if env[:method] == :delete && env["HTTP_ACCEPT"] == SimpleJsonapi::MIME_TYPE && JSON.parse(env[:params]).present?
      env[:input] = env[:params]
    end

    super(uri, env, &block)
  end
end

Rack::Test::Session.prepend(PatchRackTestDeleteRequests)

ActiveSupport.on_load(:action_controller) do
  ActionDispatch::IntegrationTest.register_encoder :jsonapi,
    param_encoder:   ->(params) { params.to_json },
    response_parser: ->(body) { JSON.parse(body) }
end
