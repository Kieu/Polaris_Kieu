class CreateExtPromotionReports < ActiveRecord::Migration
  def change
    create_table :ext_promotion_reports do |t|
      t.integer :promotion_id
      t.integer :media_category_id
      t.integer :media_id
      t.integer :account_id
      t.integer :imp
      t.integer :click
      t.integer :cost
      t.date :report_date

      t.timestamps
    end
  end
end
