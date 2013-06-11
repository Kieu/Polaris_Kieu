class CreateCreatives < ActiveRecord::Migration
  def change
    create_table :creatives do |t|
      t.integer :ad_id, limt: 11
      t.string :creative_name, limit: 256
      t.string :image, limit: 512
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11
      t.datetime :create_time
      t.datetime :update_time
    end
  end
end
