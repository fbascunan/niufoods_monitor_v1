# == Schema Information
#
# Table name: devices
#
#  id               :bigint           not null, primary key
#  device_type      :string           not null
#  last_check_in_at :datetime
#  status           :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  restaurant_id    :bigint           not null
#
# Indexes
#
#  index_devices_on_restaurant_id  (restaurant_id)
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

  validates :status, inclusion: { in: statuses.keys }
end
