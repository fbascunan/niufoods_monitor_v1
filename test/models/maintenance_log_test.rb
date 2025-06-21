# == Schema Information
#
# Table name: maintenance_logs
#
#  id                 :bigint           not null, primary key
#  description        :text
#  device_status      :string
#  maintenance_status :string           default("pending")
#  performed_at       :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  device_id          :bigint           not null
#
# Indexes
#
#  index_maintenance_logs_on_device_id                   (device_id)
#  index_maintenance_logs_on_device_id_and_performed_at  (device_id,performed_at DESC)
#  index_maintenance_logs_on_performed_at                (performed_at)
#
# Foreign Keys
#
#  fk_rails_...  (device_id => devices.id)
#
require "test_helper"

class MaintenanceLogTest < ActiveSupport::TestCase
  def setup
    @device = devices(:pos_terminal_1)
    @maintenance_log = maintenance_logs(:one)
  end

  test "should be valid with valid attributes" do
    assert @maintenance_log.valid?
  end

  test "should require performed_at" do
    @maintenance_log.performed_at = nil
    assert_not @maintenance_log.valid?
    assert_includes @maintenance_log.errors[:performed_at], "can't be blank"
  end

  test "should require device" do
    @maintenance_log.device = nil
    assert_not @maintenance_log.valid?
    assert_includes @maintenance_log.errors[:device], "must exist"
  end

  test "should require maintenance_status" do
    @maintenance_log.maintenance_status = nil
    assert_not @maintenance_log.valid?
    assert_includes @maintenance_log.errors[:maintenance_status], "can't be blank"
  end

  test "should belong to device" do
    assert_respond_to @maintenance_log, :device
    assert_equal @device, @maintenance_log.device
  end

  test "should have default maintenance_status of pending" do
    new_log = MaintenanceLog.new(
      device: @device,
      description: "Test log",
      performed_at: Time.current,
      device_status: "activo"
    )
    new_log.save!
    
    assert_equal "pending", new_log.maintenance_status
  end

  test "should accept valid maintenance_status values" do
    valid_statuses = ["pending", "in_progress", "completed", "failed", "cancelled"]
    
    valid_statuses.each do |status|
      @maintenance_log.maintenance_status = status
      assert @maintenance_log.valid?, "#{status} should be a valid maintenance_status"
    end
  end

  test "should accept valid device_status values" do
    valid_statuses = ["activo", "advertencia", "critico", "inactivo"]
    
    valid_statuses.each do |status|
      @maintenance_log.device_status = status
      assert @maintenance_log.valid?, "#{status} should be a valid device_status"
    end
  end

  test "should set device_status automatically if not provided" do
    new_log = MaintenanceLog.new(
      device: @device,
      description: "Test log",
      performed_at: Time.current,
      maintenance_status: "pending"
    )
    new_log.save!
    
    assert_equal @device.status, new_log.device_status
  end

  test "should allow description to be nil" do
    @maintenance_log.description = nil
    assert @maintenance_log.valid?
  end

  test "should allow description to be empty" do
    @maintenance_log.description = ""
    assert @maintenance_log.valid?
  end

  test "should allow long descriptions" do
    long_description = "A" * 1000
    @maintenance_log.description = long_description
    assert @maintenance_log.valid?
    assert_equal long_description, @maintenance_log.description
  end

  test "should be able to set performed_at to future date" do
    future_time = Time.current + 1.day
    @maintenance_log.performed_at = future_time
    assert @maintenance_log.valid?
    assert_in_delta future_time, @maintenance_log.performed_at, 1.second
  end

  test "should be able to set performed_at to past date" do
    past_time = Time.current - 1.day
    @maintenance_log.performed_at = past_time
    assert @maintenance_log.valid?
    assert_in_delta past_time, @maintenance_log.performed_at, 1.second
  end

  test "should be able to update maintenance_status" do
    @maintenance_log.update!(maintenance_status: "completed")
    assert_equal "completed", @maintenance_log.reload.maintenance_status
  end

  test "should be able to update device_status" do
    @maintenance_log.update!(device_status: "critico")
    assert_equal "critical", @maintenance_log.reload.device_status
  end

  test "should be able to update description" do
    new_description = "Updated maintenance description"
    @maintenance_log.update!(description: new_description)
    assert_equal new_description, @maintenance_log.reload.description
  end

  test "should be able to update performed_at" do
    new_time = Time.current + 2.hours
    @maintenance_log.update!(performed_at: new_time)
    assert_in_delta new_time, @maintenance_log.reload.performed_at, 1.second
  end

  test "should have maintenance_status scopes" do
    assert_respond_to MaintenanceLog, :completed
    assert_respond_to MaintenanceLog, :pending
    assert_respond_to MaintenanceLog, :failed
  end

  test "should have recent scope" do
    assert_respond_to MaintenanceLog, :recent
  end

  test "should have maintenance_status enum methods" do
    assert @maintenance_log.respond_to?(:maintenance_pending?)
    assert @maintenance_log.respond_to?(:maintenance_completed?)
    assert @maintenance_log.respond_to?(:maintenance_failed?)
  end

  test "should have device_status enum methods" do
    assert @maintenance_log.respond_to?(:device_active?)
    assert @maintenance_log.respond_to?(:device_critical?)
    assert @maintenance_log.respond_to?(:device_warning?)
  end
end
