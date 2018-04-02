module SimpleJsonapi
  module Errors
    class ActiveModelError
      def self.from_errors(errors, pointer_mapping = {})
        errors.keys.flat_map do |attribute|
          errors.full_messages_for(attribute).map do |message|
            new(attribute, message, pointer_mapping[attribute])
          end
        end
      end

      attr_reader :attribute, :message, :pointer

      def initialize(attribute, message, pointer)
        @attribute = attribute.to_s
        @message = message.to_s
        @pointer = pointer.to_s
      end
    end
  end
end
