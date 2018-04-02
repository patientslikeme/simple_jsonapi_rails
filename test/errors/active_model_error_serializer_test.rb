require_relative '../test_helper'

class ActiveModelErrorSerializerTest < Minitest::Spec
  let(:attribute_error) do
    SimpleJsonapi::Errors::ActiveModelError.new("the_attribute", "the_message", "the_pointer")
  end
  let(:generic_error) do
    SimpleJsonapi::Errors::ActiveModelError.new(nil, "the_message", nil)
  end

  let(:serialized_attribute_error) do
    SimpleJsonapi.render_errors(attribute_error).dig(:errors, 0)
  end
  let(:serialized_generic_error) do
    SimpleJsonapi.render_errors(generic_error).dig(:errors, 0)
  end

  describe SimpleJsonapi::Errors::ActiveModelErrorSerializer do
    it "has a status of 422" do
      assert_equal "422", serialized_attribute_error[:status]
    end

    it "has a code of unprocessable_entity" do
      assert_equal "unprocessable_entity", serialized_attribute_error[:code]
    end

    it "has the attribute name in the title" do
      assert_equal "Invalid the_attribute", serialized_attribute_error[:title]
    end

    it "has a generic title if the attribute is blank" do
      assert_equal "Invalid record", serialized_generic_error[:title]
    end

    it "has the full message as the detail" do
      assert_equal "the_message", serialized_attribute_error[:detail]
    end

    it "includes the source pointer" do
      assert_equal "the_pointer", serialized_attribute_error.dig(:source, :pointer)
    end

    it "ignores a missing source pointer" do
      assert_nil serialized_generic_error.dig(:source, :pointer)
    end
  end
end
