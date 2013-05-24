class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :promotion_name
      t.integer :promotion_category_id
      t.integer :client_id
      t.integer :create_user_id
      t.integer :update_user_id
      t.integer :del_flg, default: 0
      t.integer :agency_id

      t.timestamps
    end
  end
end
