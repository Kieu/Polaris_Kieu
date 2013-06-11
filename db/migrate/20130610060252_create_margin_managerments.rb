class CreateMarginManagerments < ActiveRecord::Migration
  def change
    create_table :margin_managerments do |t|
      t.integer :report_ymd
      t.integer :account_id
      t.string :margin_rate
      t.datetime :create_time
      t.integer :create_user_id
      t.integer :update_user_id
      t.datetime :update_time

      t.timestamps
    end
  end
end
