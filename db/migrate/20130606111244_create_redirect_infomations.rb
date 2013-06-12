class CreateRedirectInfomations < ActiveRecord::Migration
  def change
    create_table :redirect_infomations do |t|
      t.string :mpv, limit: 255
      t.integer :client_id, limit: 11
      t.integer :promotion_id, limit: 11
      t.integer :media_category_id, limit: 11
      t.integer :media_id, limit: 11
      t.integer :account_id, limit: 11
      t.integer :campaign_id, limit: 20
      t.integer :group_id, limit: 20
      t.integer :unit_id, limit: 20
      t.integer :creative_id, limit: 20
      t.integer :click_unit, limit: 11
      t.text :comment
      t.string :del_flg, limit: 1
      t.datetime :create_at
      t.integer :create_usr_id, limit: 11
      t.datetime :update_at
      t.integer :update_usr_id, limit: 11
    end
  end
end
