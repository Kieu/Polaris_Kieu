class ChangeColumsFromMarginTable < ActiveRecord::Migration
  def change
    remove_column :margin_managements, :account_id
    remove_column :margin_managements, :integer

    add_column :margin_managements, :account_id, :integer
  end
end
