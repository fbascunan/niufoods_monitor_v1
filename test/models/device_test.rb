# == Schema Information
#
# Table name: devices
#
#  id               :bigint           not null, primary key
#  device_type      :string           not null
#  last_check_in_at :datetime
#  model            :string
#  name             :string
#  serial_number    :string
#  status           :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  restaurant_id    :bigint           not null
#
# Indexes
#
#  index_devices_on_id             (id)
#  index_devices_on_restaurant_id  (restaurant_id)
#  index_devices_on_serial_number  (serial_number)
#  index_devices_on_status         (status)
#
# Foreign Keys
#
#  fk_rails_...  (restaurant_id => restaurants.id)
#
require "test_helper"

class DeviceTest < ActiveSupport::TestCase
  def setup
    @device = devices(:pos_terminal_1)
    @restaurant = @device.restaurant
  end

  test "should be valid with valid attributes" do
    assert @device.valid?
  end

  test "should require status" do
    @device.status = nil
    assert_not @device.valid?
    assert_includes @device.errors[:status], "can't be blank"
  end

  test "should require valid status" do
    assert_raises ArgumentError do
      @device.status = "invalid_status"
    end
  end

  test "should require device_type" do
    @device.device_type = nil
    assert_not @device.valid?
    assert_includes @device.errors[:device_type], "can't be blank"
  end

  test "should belong to restaurant" do
    assert_respond_to @device, :restaurant
    assert_equal @restaurant, @device.restaurant
  end

  test "should have many maintenance logs" do
    assert_respond_to @device, :maintenance_logs
  end

  test "should destroy associated maintenance logs when deleted" do
    maintenance_log = @device.maintenance_logs.create!(
      description: "Test log",
      performed_at: Time.current,
      status: "completed"
    )
    
    @device.destroy
    assert_not MaintenanceLog.exists?(maintenance_log.id)
  end

  test "should have correct status enum values" do
    assert_equal "activo", Device.statuses[:active]
    assert_equal "advertencia", Device.statuses[:warning]
    assert_equal "critico", Device.statuses[:critical]
    assert_equal "inactivo", Device.statuses[:inactive]
  end

  test "should accept valid status values" do
    Device.statuses.each do |status_key, status_value|
      @device.status = status_value
      assert @device.valid?, "#{status_value} should be a valid status"
    end
  end

  test "should update last_check_in_at when status changes" do
    old_check_in = @device.last_check_in_at
    @device.update!(status: :warning)
    
    assert_not_equal old_check_in, @device.reload.last_check_in_at
  end

  test "should be able to set optional attributes" do
    @device.name = "Test Device"
    @device.model = "Test Model"
    @device.serial_number = "SN123456"
    
    assert @device.valid?
    assert_equal "Test Device", @device.name
    assert_equal "Test Model", @device.model
    assert_equal "SN123456", @device.serial_number
  end

  test "should handle nil optional attributes" do
    @device.name = nil
    @device.model = nil
    @device.serial_number = nil
    
    assert @device.valid?
  end

  test "should be able to update last_check_in_at independently" do
    new_time = Time.current + 1.hour
    @device.update!(last_check_in_at: new_time)
    
    # Compare only up to seconds precision to avoid microsecond differences
    assert_equal new_time.to_i, @device.reload.last_check_in_at.to_i
  end
end
