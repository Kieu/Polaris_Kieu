class CreateRedirectUrls < ActiveRecord::Migration
  def change
    create_table :redirect_urls do |t|
      t.string :mpv, limit: 255
      t.text :url
      t.integer :rate, limit: 11
      t.string :name, limit: 255
      t.integer :create_user_id, limit: 11
      t.integer :update_user_id, limit: 11
      t.datetime :create_time
      t.datetime :update_time
    end
  end
end
