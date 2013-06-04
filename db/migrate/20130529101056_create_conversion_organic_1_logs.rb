class CreateConversionOrganic1Logs < ActiveRecord::Migration
  def change
    create_table :conversion_organic_1_logs do |t|
      t.integer :conversion_id
      t.integer :redirect_infomation_id
      t.string :verify
      t.string :suid
      t.text :reqest_url
      t.text :redirect_url
      t.string :media_session_id
      t.string :device_category
      t.text :user_agent
      t.text :referrer
      t.integer :access_time
      t.integer :access_vmd
      t.string :remote_ip
      t.string :conversion_category
      t.string :conversion_type
      t.string :repeat_flg
      t.string :repeat_proccessed_flg
      t.integer :parent_conversion_id
      t.integer :sales
      t.integer :profit
      t.integer :volume
      t.text :others

      t.timestamps
    end
  end
end
