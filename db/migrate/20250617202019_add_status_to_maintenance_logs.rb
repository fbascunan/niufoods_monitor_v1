class AddStatusToMaintenanceLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :maintenance_logs, :status, :string, default: "pending"
  end
end
