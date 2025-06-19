require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get devices_show_url
    assert_response :success
  end
end
