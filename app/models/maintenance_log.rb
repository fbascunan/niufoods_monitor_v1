# == Schema Information
#
# Table name: maintenance_logs
#
#  id                 :bigint           not null, primary key
#  description        :text
#  performed_at       :datetime         not null
#  device_status      :string
#  maintenance_status :string           default("pending")
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
class MaintenanceLog < ApplicationRecord
  belongs_to :device

  # Device status enum - reflects the device's status at the time of maintenance
  enum device_status: {
    active: "activo",
    warning: "advertencia", 
    critical: "critico",
    inactive: "inactivo"
  }, _prefix: :device

  # Maintenance status enum - reflects the status of the maintenance task itself
  enum maintenance_status: {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed",
    failed: "failed",
    cancelled: "cancelled"
  }, _prefix: :maintenance

  validates :device, presence: true
  validates :performed_at, presence: true
  validates :maintenance_status, presence: true
  validates :device_status, presence: true

  # Scope to find recent maintenance logs
  scope :recent, -> { order(performed_at: :desc) }
  
  # Scope to find completed maintenance
  scope :completed, -> { where(maintenance_status: "completed") }
  
  # Scope to find pending maintenance
  scope :pending, -> { where(maintenance_status: "pending") }
  
  # Scope to find failed maintenance
  scope :failed, -> { where(maintenance_status: "failed") }

  # Set device_status to current device status if not provided
  before_validation :set_device_status_if_missing

  private

  def set_device_status_if_missing
    if device_status.blank? && device.present?
      self.device_status = device.status
    end
  end
end
