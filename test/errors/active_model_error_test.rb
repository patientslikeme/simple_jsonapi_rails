require_relative '../test_helper'

class ActiveModelErrorTest < Minitest::Spec
  class Order
    include ActiveModel::Model
    attr_accessor :customer_name, :description
    validates :customer_name, presence: true
    validates :description, presence: true
  end

  let(:invalid_order) { Order.new.tap(&:valid?) }

  describe SimpleJsonapi::Errors::ActiveModelError do
    describe "#initialize" do
      let(:error) { SimpleJsonapi::Errors::ActiveModelError.new("the_attribute", "the_message", "the_pointer") }

      it "takes an attribute, a message, and a pointer" do
        assert_equal "the_attribute", error.attribute
        assert_equal "the_message", error.message
        assert_equal "the_pointer", error.pointer
      end
    end

    describe ".from_errors" do
      let(:pointer_mapping) do
        {
          customer_name: "/data/attributes/customer_name",
          description: "/data/attributes/description",
        }
      end

      let(:errors) do
        SimpleJsonapi::Errors::ActiveModelError.from_errors(invalid_order.errors, pointer_mapping)
      end

      it "converts an ActiveModel::Errors object" do
        assert_equal ["customer_name", "description"], errors.map(&:attribute).sort
        assert_equal ["Customer name can't be blank", "Description can't be blank"], errors.map(&:message).sort
      end

      it "incorporates a pointer mapping" do
        assert_equal ["/data/attributes/customer_name", "/data/attributes/description"], errors.map(&:pointer).sort
      end
    end
  end
end
