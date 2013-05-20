class CreateAgencies < ActiveRecord::Migration
  def change
    create_table :agencies do |t|
      t.string :agency_name
      t.string :roman_name
      t.integer :create_user_id
      t.integer :update_user_id

      t.timestamps
    end
    add_index :agencies, :agency_name, unique: true
    add_index :agencies, :roman_name, unique: true
  end
end
