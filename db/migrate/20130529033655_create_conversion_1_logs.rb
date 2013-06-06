class CreateConversion1Logs < ActiveRecord::Migration
  def change
    create_table :conversion_1_logs do |t|
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
      t.text :request_uri
      t.text :request_url
      t.text :redirect_url
      t.string :media_session_id
      t.string :device_category
      t.text :user_agent
      t.text :referrer
      t.text :click_referrer
      t.string :repeat_proccessed_flg
      t.string :parent_conversion_id
      t.integer :access_time
      t.integer :access_vmd
      t.integer :click_time
      t.string :remote_ip
      t.string :mark
      t.string :conversion_category
      t.string :conversion_type
      t.string :repeat_flg
      t.integer :profit
      t.integer :volume
      t.string :approval_status
      t.text :send_url
      t.integer :send_utime
      t.string :access_track_server

      t.timestamps
    end
  end
end
