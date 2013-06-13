class ChangeColumnDb < ActiveRecord::Migration
  def change
  	remove_column :redirect_urls, :create_time

  	add_column :redirect_infomations, :create_user_id, :integer, limit: 11
  	add_column :redirect_infomations, :update_user_id, :integer, limit: 11
  	add_column :redirect_urls, :create_at, :datetime
  	add_column :redirect_urls, :update_at, :datetime
  end
end
