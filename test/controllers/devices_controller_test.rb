require "test_helper"

class DevicesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @device = devices(:pos_terminal_1)
  end

  test "should get show" do
    get device_path(@device)
    assert_response :success
  end

  test "should redirect to restaurants for non-existent device" do
    get device_path(0)
    assert_response :redirect
    assert_redirected_to restaurants_path
  end
end
