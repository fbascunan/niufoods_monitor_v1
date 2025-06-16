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
