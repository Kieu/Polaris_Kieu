class ChangeColumnDisplayAd < ActiveRecord::Migration
	remove_column :display_ads, :created_at
	remove_column :display_ads, :updated_at

	add_column :display_ads, :create_at, :datetime
	add_column :display_ads, :update_at, :datetime
end
