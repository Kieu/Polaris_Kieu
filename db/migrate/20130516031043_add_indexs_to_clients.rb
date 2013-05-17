class AddIndexsToClients < ActiveRecord::Migration
  def change
    add_index :clients, :roman_name, unique: true
    add_index :clients, :tel, unique: true
  end
end
