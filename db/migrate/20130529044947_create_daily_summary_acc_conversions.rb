class CreateDailySummaryAccConversions < ActiveRecord::Migration
  def change
    create_table :daily_summary_acc_conversions do |t|
      t.column :id, 'bigint', limit:11
      t.integer :report_ymd, limit: 11
      t.integer :promotion_id, limit: 11
      t.integer :account_id, limit: 11
      t.integer :conversion_id, limit:11
      t.integer :total_cv_count, limit: 11
      t.integer :first_cv_count, limit: 11
      t.integer :repeat_cv_count, limit: 11
      t.float :conversion_rate
      t.integer :click_per_action, limit: 11
      t.integer :assist_count, limit: 11
      t.integer :sales, limit: 11
      t.float :roas
      t.column :profit, 'bigint', limit: 20
      t.float :roi
      t.datetime :create_time
      t.datetime :update_time
    end
  end
end
