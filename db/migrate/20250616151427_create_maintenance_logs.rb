class CreateMaintenanceLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :maintenance_logs do |t|
      t.references :device, null: false, foreign_key: true
      t.datetime :performed_at, null: false
      t.text :description

      t.timestamps
    end
  end
end
