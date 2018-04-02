module SimpleJsonapi
  module Errors
    class ActiveModelErrorSerializer < ErrorSerializer
      status "422"
      code "unprocessable_entity"

      title { |err| "Invalid #{err.attribute.presence || 'record'}" }
      detail { |err| err.message }

      source do
        pointer(if: ->(err) { err.pointer.present? }) { |err| err.pointer }
      end
    end
  end
end
