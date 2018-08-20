require "test_helper"

class TestHelpersTest < ActionDispatch::IntegrationTest
  before do
    @controller = OrdersController.new
    @routes = Dummy::Application.routes
  end

  let(:order) { Order.create!(customer_name: "Customer X", date: Date.today) }
  let(:response_json) { response.parsed_body }

  describe "parameter encoder" do
    it "sends a DELETE request with no body as jsonapi" do
      delete order_path(order), as: :jsonapi
      assert_response :no_content
      assert_operator response.parsed_body, :blank?
    end

    it "sends a DELETE request with a body as jsonapi" do
      delete order_path(order), params: { data: { id: "foo" } }, as: :jsonapi
      assert_response :no_content
    end
  end
end
