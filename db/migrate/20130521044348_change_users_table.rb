class ChangeUsersTable < ActiveRecord::Migration
  def change
    add_column :users, :company_id, :integer
    remove_column :users, :company
  end
end