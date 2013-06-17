class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :promotion_name
      t.integer :promotion_category_id
      t.integer :client_id
      t.integer :create_user_id
      t.integer :update_user_id
      t.string :del_flg, limit 1

      t.timestamps
    end
  end
end
