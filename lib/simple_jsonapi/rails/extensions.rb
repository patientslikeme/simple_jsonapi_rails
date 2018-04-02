module SimpleJsonapi
  module Rails
    module RouteHelpers
      private

      def routes
        ::Rails.application.routes.url_helpers
      end
    end

    SimpleJsonapi::Serializer.include(RouteHelpers)
  end
end
