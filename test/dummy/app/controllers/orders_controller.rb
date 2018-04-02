class OrdersController < ApiController
  jsonapi_deserialize :order

  SORT_OPTIONS = {
    customer_name: "lower(customer_name)",
    date: "date",
  }.freeze

  def index
    orders = Order.all
      # order(jsonapi.sort_sql(SORT_OPTIONS, :name, :asc)).
      # paginate(jsonapi.will_paginate_options)

    render jsonapi_resources: orders, serializer: OrderSerializer,
      include: jsonapi.include_params
  end

  def show
    order = Order.find(params[:id])
    render jsonapi_resource: order, serializer: OrderSerializer
  end

  def create
    order = Order.create!(order_params)
    render jsonapi_resource: order, serializer: OrderSerializer, status: :created
  end

  def update
    order = Order.find(params[:id]).update!(order_params)
    render jsonapi_resource: order, serializer: OrderSerializer, status: :ok
  end

  private

  def order_params
    params.require(:order).permit(:customer_name, :date)
  end
end
