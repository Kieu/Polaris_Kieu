class CreateClientUsers < ActiveRecord::Migration
  def change
    create_table :client_users do |t|
      t.integer :client_id
      t.integer :user_id
      t.integer :del_flg, default: 0

      t.timestamps
    end
    add_index :client_users, [:client_id, :user_id], unique: true
  end
end
