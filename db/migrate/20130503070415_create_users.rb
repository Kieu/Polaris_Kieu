class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :roman_name
      t.string :password_digest
      t.string :email
      t.string :company
      t.integer :role_id
      t.string :password_flg, limit: 1
      t.string :language
      t.datetime :last_login
      t.string :status, limit: 1
      t.integer :create_user_id
      t.integer :update_user_id

      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
  end
end
