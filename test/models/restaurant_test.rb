# == Schema Information
#
# Table name: restaurants
#
#  id         :bigint           not null, primary key
#  address    :string
#  email      :string
#  location   :string
#  name       :string           not null
#  phone      :string
#  status     :string
#  timezone   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_restaurants_on_name    (name) UNIQUE
#  index_restaurants_on_status  (status)
#
require "test_helper"

class RestaurantTest < ActiveSupport::TestCase
  def setup
    @restaurant = restaurants(:one)
  end

  test "should be valid with valid attributes" do
    assert @restaurant.valid?
  end

  test "should require name" do
    @restaurant.name = nil
    assert_not @restaurant.valid?
    assert_includes @restaurant.errors[:name], "can't be blank"
  end

  test "should require unique name" do
    duplicate_restaurant = @restaurant.dup
    assert_not duplicate_restaurant.valid?
    assert_includes duplicate_restaurant.errors[:name], "has already been taken"
  end

  test "should have many devices" do
    assert_respond_to @restaurant, :devices
  end

  test "should destroy associated devices when deleted" do
    device_count = @restaurant.devices.count
    assert device_count > 0, "Restaurant should have devices for this test"
    
    @restaurant.destroy
    assert_equal 0, Device.where(restaurant_id: @restaurant.id).count
  end

  test "should have correct status enum values" do
    assert_equal "activo", Restaurant.statuses[:active]
    assert_equal "advertencia", Restaurant.statuses[:warning]
    assert_equal "critico", Restaurant.statuses[:critical]
    assert_equal "inactivo", Restaurant.statuses[:inactive]
  end

  test "should recalculate status to critical when any device is critical" do
    @restaurant.update!(status: :active)
    @restaurant.devices.first.update!(status: :critical)
    
    @restaurant.recalculate_status
    assert_equal "critical", @restaurant.reload.status
  end

  test "should recalculate status to warning when any device is warning" do
    @restaurant.update!(status: :active)
    @restaurant.devices.first.update!(status: :warning)
    
    @restaurant.recalculate_status
    assert_equal "warning", @restaurant.reload.status
  end

  test "should recalculate status to active when all devices are active" do
    @restaurant.update!(status: :critical)
    @restaurant.devices.each { |device| device.update!(status: :active) }
    
    @restaurant.recalculate_status
    assert_equal "active", @restaurant.reload.status
  end

  test "should prioritize critical over warning status" do
    @restaurant.update!(status: :active)
    @restaurant.devices.first.update!(status: :critical)
    @restaurant.devices.last.update!(status: :warning)
    
    @restaurant.recalculate_status
    assert_equal "critical", @restaurant.reload.status
  end

  test "should handle empty devices list" do
    restaurant = Restaurant.create!(name: "Empty Restaurant")
    assert_nothing_raised do
      restaurant.recalculate_status
    end
  end
end
