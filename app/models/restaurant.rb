class Restaurant < ApplicationRecord
    has_many :devices, dependent: :destroy

    validates :name, presence: true, uniqueness: true
    
    enum status: {
        active: "activo",
        warning: "advertencia",
        critical: "critico",
        inactive: "inactivo"
    }
end
