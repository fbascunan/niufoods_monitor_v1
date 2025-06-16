# == Schema Information
#
# Table name: restaurants
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_restaurants_on_name  (name) UNIQUE
#
class Restaurant < ApplicationRecord
    has_many :devices, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    
    enum status: {
        active: "activo",
        warning: "advertencia",
        critical: "critico",
        inactive: "inactivo"
    }

    def recalculate_status
        if devices.any? { |device| device.status == "critical" }
            update(status: "critical")
        elsif devices.any? { |device| device.status == "warning" }
            update(status: "warning")
        else
            update(status: "active")
        end
    end
end
