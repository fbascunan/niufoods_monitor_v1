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
class Device < ApplicationRecord
  belongs_to :restaurant
  has_many :maintenance_logs, dependent: :destroy

  enum status: {
    active: "activo",
    warning: "advertencia",
    critical: "critico",
    inactive: "inactivo"
  }

  validates :device_type, presence: true
  validates :restaurant, presence: true
  validates :status, presence: true

  # Update last_check_in_at when status changes
  before_update :update_last_check_in_at, if: :status_changed?

  private

  def update_last_check_in_at
    self.last_check_in_at = Time.current
  end
end
