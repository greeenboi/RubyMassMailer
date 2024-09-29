require "test_helper"

class Api::V1::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get api_v1_emails_create_url
    assert_response :success
  end
end
