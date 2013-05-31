class CreateDailySummaryAccounts < ActiveRecord::Migration
  def change
    create_table :daily_summary_accounts do |t|
      t.integer :media_category_id, limit: 11
      t.integer :media_id,  limit: 11
      t.integer :account_id, limit: 11
      t.integer :promotion_id, limit: 11
      t.column :imp_count, 'bigint', limit: 20
      t.column :click_count, 'bigint', limit: 20
      t.float :click_through_ratio
      t.column :cost_sum, 'bigint', limit: 20
      t.float :cost_per_click
      t.float :cost_per_mille
      t.integer :report_ymd, limit: 11
      t.datetime :create_time
      t.datetime :update_time
      t.timestamps
    end
  end
end
