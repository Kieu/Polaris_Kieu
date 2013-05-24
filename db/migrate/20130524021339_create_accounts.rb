class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer :promotion_id
      t.integer :media_id
      t.string :sync_account_id
      t.string :sync_account_pw
      t.string :account_name
      t.string :roman_name
      t.integer :sync_flg
      t.integer :cost
      t.integer :create_user_id
      t.integer :update_user_id

      t.timestamps
    end
  end
end
