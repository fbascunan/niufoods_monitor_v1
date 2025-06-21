class ReplaceStatusWithDeviceAndMaintenanceStatusInMaintenanceLogs < ActiveRecord::Migration[7.1]
  def up
    # Add new columns
    add_column :maintenance_logs, :device_status, :string
    add_column :maintenance_logs, :maintenance_status, :string, default: "pending"
    
    # Migrate existing data
    # For existing records, we'll set device_status to the current status value
    # and maintenance_status to "completed" since they already have a status
    execute <<-SQL
      UPDATE maintenance_logs 
      SET device_status = status, 
          maintenance_status = CASE 
            WHEN status IN ('completed', 'successful', 'done') THEN 'completed'
            WHEN status IN ('pending', 'scheduled') THEN 'pending'
            WHEN status IN ('in_progress', 'ongoing') THEN 'in_progress'
            WHEN status IN ('failed', 'cancelled') THEN 'failed'
            ELSE 'completed'
          END
    SQL
    
    # Remove the old status column
    remove_column :maintenance_logs, :status
  end

  def down
    # Add back the old status column
    add_column :maintenance_logs, :status, :string, default: "pending"
    
    # Migrate data back (use maintenance_status as the primary status)
    execute <<-SQL
      UPDATE maintenance_logs 
      SET status = maintenance_status
    SQL
    
    # Remove the new columns
    remove_column :maintenance_logs, :device_status
    remove_column :maintenance_logs, :maintenance_status
  end
end
