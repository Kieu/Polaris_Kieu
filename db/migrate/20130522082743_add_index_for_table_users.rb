class AddIndexForTableUsers < ActiveRecord::Migration
  def change
    add_index :users, :roman_name, unique: true
  end
end
