class OrderSerializer < SimpleJsonapi::Serializer
  type "orders"

  attribute :customer_name
  attribute :date
end
