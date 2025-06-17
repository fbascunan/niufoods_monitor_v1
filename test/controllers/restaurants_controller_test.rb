require "test_helper"

class RestaurantsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get restaurants_path
    assert_response :success
  end

  test "should get show" do
    restaurant = Restaurant.create!(name: "Test Restaurant")
    get restaurant_path(restaurant)
    assert_response :success
  end
end
