class CreateConversions < ActiveRecord::Migration
  def change
    create_table :conversions do |t|
      t.integer :promotion_id
      t.integer :os
      t.string :conversion_name
      t.integer :conversion_type
      t.integer :duplicate_flg
      t.integer :track_period
      t.integer :start_point_flg
      t.integer :sale_unit
      t.integer :pay_type
      t.text :redirect_page
      t.string :facebook_app_id
      t.integer :track_type
      t.integer :meta_data_id
      t.integer :update_user_id
      t.integer :create_user_id
      t.text :conversion_combine
      t.string :roman_name
      t.integer :unique_definition
      t.integer :track_method
      t.integer :track_media
      t.integer :review_flg

      t.timestamps
    end
      add_index :conversions, :conversion_name, unique: true
      add_index :conversions, :roman_name, unique: true
  end
end
