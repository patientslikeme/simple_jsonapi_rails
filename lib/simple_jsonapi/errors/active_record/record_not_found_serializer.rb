module SimpleJsonapi
  module Errors
    module ActiveRecord
      class RecordNotFoundSerializer < SimpleJsonapi::ErrorSerializer
        status "404"
        code "not_found"
        title "Not found"
        detail { |ex| ex.message }
        source do
          parameter { |ex| ex.primary_key }
        end
      end
    end
  end
end
