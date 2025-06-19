class AddIndexesForPerformance < ActiveRecord::Migration[7.1]
  def change
    # Index for device lookups by ID (already exists but ensuring it's optimized)
    add_index :devices, :id if !index_exists?(:devices, :id)
    
    # Index for maintenance logs by device_id and performed_at for fast ordering
    add_index :maintenance_logs, [:device_id, :performed_at], order: { performed_at: :desc }
    
    # Index for device serial_number lookups (used in API)
    add_index :devices, :serial_number if !index_exists?(:devices, :serial_number)
    
    # Index for device status updates
    add_index :devices, :status
    
    # Index for restaurant status calculations
    add_index :restaurants, :status
    
    # Index for maintenance logs by performed_at for general queries
    add_index :maintenance_logs, :performed_at, order: :desc
  end
end
