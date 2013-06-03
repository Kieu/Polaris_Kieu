class ChangePromotions < ActiveRecord::Migration
  def change
    remove_index :promotions, :promotion_name
    remove_index :promotions, :roman_name
    add_index :promotions, [:promotion_name, :client_id], unique: true
    add_index :promotions, [:roman_name, :client_id], unique: true
  end
end
