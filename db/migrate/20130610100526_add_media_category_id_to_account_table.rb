class AddFieldToAccountTable < ActiveRecord::Migration
  def change
    add_column :accounts, :media_category_id, :integer
  end
end
