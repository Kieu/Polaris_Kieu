class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :role_name
      t.integer :status, default: 0
      t.integer :create_user_id
      t.integer :update_user_id

      t.timestamps
    end
    add_index :roles, :role_name, unique: true
  end
end
