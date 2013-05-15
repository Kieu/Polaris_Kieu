class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :role_id
      t.string :username
      t.string :fullname
      t.string :password_digest
      t.string :email
      t.datetime :last_login
      t.string :language
      t.integer :status, default: 0
      t.integer :password_flg
      t.integer :create_user_id
      t.integer :update_user_id

      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :email, unique: true
  end
end
