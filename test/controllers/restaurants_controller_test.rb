require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @restaurant = restaurants(:one)
  end

  test "should get index" do
    get restaurants_path
    assert_response :success
  end

  test "should get show" do
    get restaurant_path(@restaurant)
    assert_response :success
  end

  test "should redirect to restaurants for non-existent restaurant" do
    get restaurant_path(0)
    assert_response :redirect
    assert_redirected_to restaurants_path
  end
end
