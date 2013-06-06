class CreateConversionError1Logs < ActiveRecord::Migration
  def change
    create_table :conversion_error_1_logs do |t|
      t.integer :media_category_id
      t.integer :media_id
      t.integer :account_id
      t.integer :campaign_id
      t.integer :ad_group_id
      t.integer :ad_id
      t.integer :conversion_id
      t.integer :redirect_infomation_id
      t.string :mpv
      t.integer :redirect_url_id
      t.integer :creative_id
      t.string :session_id
      t.string :verify
      t.string :suid
      t.text :reqest_url
      t.text :redirect_url
      t.string :media_session_id
      t.string :device_category
      t.text :user_agent
      t.text :referrer
      t.text :click_referrer
      t.integer :access_time
      t.integer :access_vmd
      t.integer :click_time
      t.string :remote_ip
      t.string :mark
      t.string :conversion_category
      t.string :conversion_type
      t.integer :sales

      t.timestamps
    end
  end
end
