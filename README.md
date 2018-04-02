# SimpleJsonapi/Rails

A library for integrating SimpleJsonapi into a Rails application.

## Installation

Add **simple\_jsonapi\_rails** to your Gemfile and include **SimpleJsonapi::Rails::ActionController** in your API controllers:

```ruby
# Gemfile
gem 'simple_jsonapi_rails'

# app/controllers/api_controller.rb
class ApiController < ApplicationController
  include SimpleJsonapi::Rails::ActionController
end
```

## Controllers, parsing, and rendering

### Index actions

Render a collection of resources with **`render jsonapi_resources:`**.

```ruby
class OrdersController < ApiController
  def index
    orders = Order.all  # search, sort, paginate, etc.
    render jsonapi_resources: orders
  end
end
```

Any additional parameters will be passed through to the serializer.

```ruby
class OrdersController < ApiController
  def index
    orders = Order.all
    render jsonapi_resources: orders,
      serializer: OrderSerializer,
      fields: jsonapi.fields_params,
      include: jsonapi.include_params,
      sort_related: jsonapi.sort_related_params,
      links: { self: "https://example.com/orders" },
      meta: { generated_at: Time.current },
      extras: { current_user: @current_user }
  end
end
```

### Show actions

Render a single resource with **`render jsonapi_resource:`**. Any additional parameters will be passed through to the serializer.

```ruby
class OrdersController < ApiController
  def show
    order = Order.find(params[:id])
    render jsonapi_resource: order,
      serializer: OrderSerializer,
      ...
  end
end
```

### Create and update actions

Incoming JSON:API documents can be parsed into a more Rails-friendly structure by calling **`jsonapi_deserialize`** in the controller class.

`jsonapi_deserialize` converts this incoming document ...

```json
{
  "data": {
    "type": "orders",
    "id": "1",
    "attributes": {
      "customer_name": "Jose",
      "date": "2017-10-01",
    },
    "relationships": {
      "customer": {
        "data": { "type": "customers", "id": "11" }
      },
      "products": {
        "data": [
          { "type": "products", "id": "21" },
          { "type": "widgets", "id": "22" },
        ]
      },
    },
  }
}
```

... to this hash ...

```ruby
{
  type: "orders",
  id: "1",
  customer_name: "Jose",
  date: "2017-10-01",
  customer_type: "customers",
  customer_id: "11",
  product_types: ["products", "widgets"],
  product_ids: ["21", "22"],
}
```

... which can then be saved with typical Rails actions.

```ruby
class OrdersController < ApiController
  jsonapi_deserialize :order, only: [:create, :update]

  def create
    order = Order.create!(order_params)
    render jsonapi_resource: order, status: :created
  end

  def update
    order = Order.find(params[:id]).update!(order_params)
    render jsonapi_resource: order, status: :ok
  end

  private
  def order_params
    params.require(:order).permit(:customer_name, :date)
  end
end
```

Note the use of bang methods (`#create!` and `#update!`). While not necessary, `ActiveRecord::RecordNotFound`, `::RecordInvalid`, and `::RecordNotSaved` exceptions will be rescued and rendered automatically.

You can also render errors explicitly with **`render jsonapi_errors:`**.

```ruby
class OrdersController < ApiController
  jsonapi_deserialize :order, only: [:create, :update]

  def create
    order = Order.new(order_params)
    if order.save
      render jsonapi_resource: order, status: :created
    else
      error = SimpleJsonapi::Errors::WrappedError.new(...)
      render jsonapi_errors: error, status: :unprocessable_entity
    end
  end
end
```

## Error handling

In addition to restructuring the incoming JSON, `jsonapi_deserialize` also stores a collection of pointers that can be used to render errors.

Calling **`jsonapi.pointers`** in a controller action returns the following structure.

```ruby
# OrdersController#create
jsonapi.pointers
=> {
  type: "/data/type",
  id: "/data/id",
  customer_name: "/data/attributes/customer_name",
  date: "/data/attributes/date",
  customer_type: "/data/relationships/customer",
  customer_id: "/data/relationships/customer",
  product_types: "/data/relationships/products",
  product_ids: "/data/relationships/products",
}
```

SimpleJsonapi/Rails also provides helpers for rendering several Rails-specific errors.

**`SimpleJsonapi::Errors::ActiveModelError`** converts an `ActiveModel::Errors` object to an array of serializable errors. This is done automatically in response to `AR::RecordInvalid` or `AR::RecordNotSaved`.

```ruby
SimpleJsonapi::Errors::ActiveModelError.from_errors(order.errors, jsonapi.pointers)
=> [
  <SimpleJsonapi::Errors::ActiveModelError
     status: "422",
     code:   "unprocessable_entity",
     title:  "Invalid customer_name",
     detail: "Customer name must be present",
     source: { pointer: "/data/attributes/customer_name" }
  >, ...
]
```

A serializer is provided for `ActiveRecord::RecordNotFound` errors, so they can be rendered directly.

```ruby
error = ActiveRecord::RecordNotFound.new(...)
render jsonapi_errors: error, status: :not_found
```

## Request Validation

SimpleJsonapi/Rails performs some basic request validations via two `before_action`s,
`validate_jsonapi_request_headers`, and `validate_jsonapi_request_body`.

The `Content-Type` header must be set to `application/vnd+api.json` if there is a response body present. If it is not a
head response will be returned with status 415 Unsupported Media Type.

The `Accept` header, if it present, must also be set to `application/vnd+api.json`. If it is not a head response will be
returned with status 406 Not Acceptable.

## Routing
Rails' route mapper works well for most jsonapi resource routes. However, simple_jsonapi_rails does supply helpers method
for defining relationship routes, which can be trickier:

```ruby
# config/routes.rb
resources :orders do
  jsonapi_to_many_relationship(:orders, :items)
  jsonapi_to_one_relationship(:orders, :customer)
end
```

This code generates the following paths and routes/controller action mappings.
```
orders_relationships_items    POST   /orders/:order_id/relationships/items(.:format)   orders/relationships/items#add
orders_relationships_items    DELETE /orders/:order_id/relationships/items(.:format)   orders/relationships/items#remove
orders_relationships_items    PATCH  /orders/:order_id/relationships/items(.:format)   orders/relationships/items#replace

orders_relationships_customer PATCH  /orders/:order_id/customer(.:format)              orders/relationships/customer#replace

```

## Running tests

1. Change to the gem's directory
2. Run `bundle install`
3. Run `bundle exec rake test`

## Release Process
Once pull request is merged to master, on latest master:
1. Update CHANGELOG.md. Version: [ major (breaking change: non-backwards
   compatible release) | minor (new features) | patch (bugfixes) ]
2. Update version in lib/global_enforcer/version.rb
3. Release by running `bundle exec rake release`

