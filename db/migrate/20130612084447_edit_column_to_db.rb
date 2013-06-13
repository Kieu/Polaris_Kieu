class EditColumnToDb < ActiveRecord::Migration
  remove_column :display_groups, :created_at
	remove_column :display_groups, :updated_at
	remove_column :display_campaigns, :created_at
	remove_column :display_campaigns, :updated_at

	add_column :display_groups, :create_at, :datetime
	add_column :display_groups, :update_at, :datetime
	add_column :display_campaigns, :create_at, :datetime
	add_column :display_campaigns, :update_at, :datetime
end
