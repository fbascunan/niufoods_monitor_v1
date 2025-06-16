class AddLastCheckInAtToDevices < ActiveRecord::Migration[7.1]
  def change
    add_column :devices, :last_check_in_at, :datetime
  end
end
