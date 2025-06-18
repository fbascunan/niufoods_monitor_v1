class AddLocationToRestaurants < ActiveRecord::Migration[7.1]
  def change
    add_column :restaurants, :location, :string
    add_column :restaurants, :address, :string
    add_column :restaurants, :phone, :string
    add_column :restaurants, :email, :string
    add_column :restaurants, :timezone, :string
  end
end
