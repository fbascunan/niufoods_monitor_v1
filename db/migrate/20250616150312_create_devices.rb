class CreateDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :devices do |t|
      t.references :restaurant, null: false, foreign_key: true
      t.string :device_type, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
