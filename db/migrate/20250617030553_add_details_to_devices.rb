class AddDetailsToDevices < ActiveRecord::Migration[7.1]
  def change
    add_column :devices, :name, :string
    add_column :devices, :model, :string
    add_column :devices, :serial_number, :string
  end
end
