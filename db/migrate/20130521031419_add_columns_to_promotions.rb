class AddColumnsToPromotions < ActiveRecord::Migration
  def change
    add_column :promotions, :roman_name, :string
    add_column :promotions, :tracking_period, :integer
    add_index :promotions, :promotion_name, unique: true
    add_index :promotions, :roman_name, unique: true
  end
end
