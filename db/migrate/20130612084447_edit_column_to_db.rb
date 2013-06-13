class EditColumnToDb < ActiveRecord::Migration
  remove_column :display_groups, :create_time
	remove_column :display_groups, :update_time
	remove_column :display_campaigns, :create_time
	remove_column :display_campaigns, :update_time

	add_column :display_groups, :create_at, :datetime
	add_column :display_groups, :update_at, :datetime
	add_column :display_campaigns, :create_at, :datetime
	add_column :display_campaigns, :update_at, :datetime
end
