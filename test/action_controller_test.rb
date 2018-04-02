require_relative 'test_helper'

class ActionControllerTest < ActionDispatch::IntegrationTest
  before do
    @controller = OrdersController.new
    @routes = Dummy::Application.routes
  end

  let(:order) { create_order }
  let(:response_json) { response.parsed_body }

  def create_order
    Order.create!(customer_name: "Customer X", date: Date.today)
  end

  describe "ActionController" do
    describe "basic get" do
      it "gets a collection of resources without parameters" do
        2.times { create_order }

        get orders_url, as: :jsonapi
        assert_equal %w[data], response_json.keys
        assert_equal(%w[orders orders], response_json["data"].map { |o| o["type"] })
      end

      it "gets a single resource without parameters" do
        get order_path(order), as: :jsonapi
        assert_equal %w[data], response_json.keys
        assert_equal "orders", response_json.dig("data", "type")
        assert_equal order.id.to_s, response_json.dig("data", "id")
      end
    end

    describe "include parameter" do
      it "splits a comma-delimited value" do
        get orders_url(include: "this,that"), as: :jsonapi
        assert_equal %w[this that], @controller.jsonapi.include_params
      end

      it "defaults to nil" do
        get orders_url, as: :jsonapi
        assert_nil @controller.jsonapi.include_params
      end
    end

    describe "fields parameter" do
      it "splits comma-delimited values" do
        input = {
          orders: "customer_name",
          line_items: "product_name,quantity",
        }
        expected_output = {
          "orders" => %w[customer_name],
          "line_items" => %w[product_name quantity],
        }

        get orders_url(fields: input), as: :jsonapi

        assert_equal expected_output, @controller.jsonapi.fields_params.to_unsafe_h
      end

      it "defaults to an empty hash" do
        get orders_url, as: :jsonapi
        assert_equal({}, @controller.jsonapi.fields_params)
      end
    end

    describe "filter_param" do
      it "fetches the parameter value" do
        get orders_url("filter[this]" => "that"), as: :jsonapi

        assert_equal "that", @controller.jsonapi.filter_param(:this)
      end
    end

    describe "filter_param_list" do
      it "splits a comma-delimited string" do
        get orders_url("filter[these]" => "that,those"), as: :jsonapi

        assert_equal %w[that those], @controller.jsonapi.filter_param_list(:these)
      end

      it "returns a simple string as an array" do
        get orders_url("filter[this]" => "that"), as: :jsonapi

        assert_equal %w[that], @controller.jsonapi.filter_param_list(:this)
      end
    end

    describe "sort_related parameter" do
      it "splits comma-delimited values" do
        input = {
          orders: "customer_name",
          line_items: "product_name,quantity",
        }
        expected_output = {
          "orders" => %w[customer_name],
          "line_items" => %w[product_name quantity],
        }

        get orders_url(sort_related: input), as: :jsonapi

        assert_equal expected_output, @controller.jsonapi.sort_related_params.to_unsafe_h
      end

      it "defaults to an empty hash" do
        get orders_url, as: :jsonapi
        assert_equal({}, @controller.jsonapi.fields_params)
      end
    end

    describe "jsonapi_deserialize" do
      let(:request_json) { request_hash.to_json }
      let(:request_hash) do
        {
          data: {
            type: "orders",
            id: "1",
            attributes: {
              customer_name: "Jose",
              date: "2017-10-01",
            },
            relationships: {
              customer: {
                data: { type: "customers", id: "11" },
              },
              products: {
                data: [
                  { type: "products", id: "21" },
                  { type: "widgets", id: "22" },
                ],
              },
            },
          },
        }
      end

      let(:helper) { SimpleJsonapi::Rails::ActionController::JsonapiHelper.new(nil) }
      let(:deserialized) { helper.deserialize(request_hash) }

      it "parses the request body" do
        post orders_url, params: request_hash, as: :jsonapi
        assert_response :created
        assert_instance_of ActionController::Parameters, @controller.params[:order]
        assert_equal "orders", @controller.params.dig(:order, :type)
        assert_equal "1", @controller.params.dig(:order, :id)
      end

      it "is a no-op if there's no request body" do
        2.times { create_order }

        get orders_url, as: :jsonapi
        assert_response :ok
        assert_nil @controller.params[:order]
      end

      it "moves the type and id to the object param" do
        assert_equal "orders", deserialized[:type]
        assert_equal "1", deserialized[:id]
      end

      it "moves the attributes to the object param" do
        assert_equal "Jose", deserialized[:customer_name]
        assert_equal "2017-10-01", deserialized[:date]
      end

      it "moves singular relationships to the object param" do
        assert_equal "customers", deserialized[:customer_type]
        assert_equal "11", deserialized[:customer_id]
      end

      it "moves collection relationships to the object param" do
        assert_equal %w[products widgets], deserialized[:product_types]
        assert_equal %w[21 22], deserialized[:product_ids]
      end
    end

    describe "rendering errors" do
      it "renders ActiveModel::Errors" do
        post orders_url, params: {
          data: {
            type: "orders",
            attributes: {
              customer_name: "",
              date: Date.today.iso8601,
            },
          },
        }, as: :jsonapi

        expected_output = {
          errors: [{
            status: "422",
            code: "unprocessable_entity",
            title: "Invalid customer_name",
            detail: "Customer name can't be blank",
            source: { pointer: "/data/attributes/customer_name" },
          },],
        }.deep_stringify_keys

        assert_response :unprocessable_entity
        assert_equal expected_output, response_json
      end

      it "renders ActiveRecord::RecordNotFound" do
        get order_path(-1), as: :jsonapi

        expected_output = {
          errors: [{
            status: "404",
            code: "not_found",
            title: "Not found",
            detail: "Couldn't find Order with 'id'=-1",
            source: { parameter: "id" },
          },],
        }.deep_stringify_keys

        assert_response :not_found
        assert_equal expected_output, response_json
      end
    end

    describe "routing" do
      it "generates correct relationship paths" do
        assert_generates "/orders/1/relationships/items",
                         controller: "orders/relationships/items",
                         action: "add",
                         id: 1

        assert_generates "/orders/1/relationships/items",
                         controller: "orders/relationships/items",
                         action: "remove",
                         id: 1

        assert_generates "/orders/1/relationships/items",
                         controller: "orders/relationships/items",
                         action: "replace",
                         id: 1
      end

      it "generates the correct path helpers" do
        assert_equal "/orders/1/relationships/items", orders_relationships_items_path(1)
      end
    end

    describe "request validation" do
      let(:request_hash) do
        {
          data: {
            type: "orders",
            attributes: {
              customer_name: "Jose",
            },
          },
        }
      end

      let(:jsonapi_mime_type) do
        SimpleJsonapi::MIME_TYPE
      end

      it "returns a 406 if there is an accept header that does not match the required mime-type" do
        get order_path(order), headers: { "Accept" => "application/json" }

        assert_response :not_acceptable
      end

      # NB: This doesn't quite test what happens if there is no accept header, since Rails not so helpfully adds in an
      # Accept header if none is present.
      it "does not require an accept header" do
        get order_path(order), headers: { "Accept" => "" }

        assert_response :ok
      end

      it "returns a 415 if there is a request body but not the proper Content Type header" do
        headers = {
          "Accept" => jsonapi_mime_type,
          "Content-Type" => "application/json",
        }

        post orders_url, params: request_hash.to_json, headers: headers

        assert_response :unsupported_media_type
      end

      it "returns a 400 if there is no data element" do
        post orders_url, params: { hinkle: "finkle_dinkle_doo" }, as: :jsonapi

        assert_response :bad_request
      end

      it "returns a 400 if the request is to a relationship and there is not a data array" do
        post orders_relationships_items_url(1), params: { data: "array non est" }, as: :jsonapi

        assert_response :bad_request
      end
    end
  end
end
