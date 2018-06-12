module SimpleJsonapi
  module Extensions
    module Routing
      ACTION_MAP = {
        add: :create,
        remove: :destroy,
        replace: :update,
        fetch: :show,
      }.freeze

      SUPPORTED_TO_MANY_ACTIONS = ACTION_MAP.keys.freeze

      def jsonapi_to_one_relationship(member_name, association)
        jsonapi_relationship([:replace], member_name, association)
      end

      def jsonapi_to_many_relationship(member_name, association, only: nil, except: nil)
        jsonapi_relationship(to_many_actions_to_define(only, except), member_name, association)
      end

      private

      def jsonapi_relationship(actions, member_name, association)
        member do
          scope as: member_name, module: member_name.to_s.pluralize do
            namespace "relationships" do
              actions.each do |action|
                resource association, only: [ACTION_MAP[action]], action: action
              end
            end
          end
        end
      end

      def to_many_actions_to_define(only, except)
        actions = if only
                    Array(only)
                  elsif except
                    SUPPORTED_TO_MANY_ACTIONS - Array(except)
                  else
                    SUPPORTED_TO_MANY_ACTIONS
                  end

        ensure_actions_supported(actions)

        actions
      end

      def ensure_actions_supported(actions)
        if actions.any? { |action| SUPPORTED_TO_MANY_ACTIONS.exclude?(action) }
          raise ArgumentError, "#jsonapi_to_many_relationship supports :add, :remove, :replace, and :fetch actions"
        end
      end
    end

    ActionDispatch::Routing::Mapper.include(SimpleJsonapi::Extensions::Routing)
  end
end
