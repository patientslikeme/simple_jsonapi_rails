require_relative '../../test_helper'

class ActiveRecord::RecordNotFoundSerializerTest < Minitest::Spec
  let(:error) do
    ActiveRecord::RecordNotFound.new("a message", "Thing", "id", 1)
  end

  let(:serialized_error) do
    SimpleJsonapi.render_errors(error).dig(:errors, 0)
  end

  describe SimpleJsonapi::Errors::ActiveRecord::RecordNotFoundSerializer do
    it "has a status of 404" do
      assert_equal "404", serialized_error[:status]
    end

    it "has a code of not_found" do
      assert_equal "not_found", serialized_error[:code]
    end

    it "has a title of Not found" do
      assert_equal "Not found", serialized_error[:title]
    end

    it "has the full message as the detail" do
      assert_equal "a message", serialized_error[:detail]
    end

    it "has the primary key as the source parameter" do
      assert_equal "id", serialized_error[:source][:parameter]
    end
  end
end
