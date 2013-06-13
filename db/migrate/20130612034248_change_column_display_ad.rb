class ChangeColumnDisplayAd < ActiveRecord::Migration
	remove_column :display_ads, :create_time
	remove_column :display_ads, :update_time

	add_column :display_ads, :create_at, :datetime
	add_column :display_ads, :update_at, :datetime
end
