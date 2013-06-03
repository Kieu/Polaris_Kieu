class CreateConversions < ActiveRecord::Migration
  def change
    create_table :conversions do |t|
      t.integer :promotion_id
      t.string :conversion_name
      t.string :roman_name
      t.integer :conversion_category
      t.integer :duplicate
      t.integer :unique_def
      t.integer :start_point
      t.integer :sale_unit_price
      t.integer :reward_form
      t.integer :os
      t.integer :conversion_mode
      t.integer :facebook_app_id
      t.integer :judging
      t.integer :track_type
      t.integer :track_method
      t.text :url
      t.integer :session_period
      t.text :conversion_combine
      t.integer :create_user_id
      t.integer :update_user_id
      t.integer :del_flg

      t.timestamps
    end
    add_index :conversions, [:promotion_id, :conversion_name], unique: true
    add_index :conversions, [:promotion_id, :roman_name], unique: true
  end
end
