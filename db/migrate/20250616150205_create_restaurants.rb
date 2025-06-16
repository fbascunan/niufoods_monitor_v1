class CreateRestaurants < ActiveRecord::Migration[7.1]
  def change
    create_table :restaurants do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :status

      t.timestamps
    end
  end
end
