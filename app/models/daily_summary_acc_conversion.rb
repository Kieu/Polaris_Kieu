class DailySummaryAccConversion < ActiveRecord::Base
  establish_connection :log_db_development
  attr_accessible :report_ymd, :account_id, :assist_count, :click_per_action,
    :conversion_id, :conversion_rate, :create_time, :first_cv_count, :id,
    :profit, :promotion_id, :repeat_cv_count, :roas, :roi, :sales,
    :total_cv_count, :update_time

  belongs_to :account
  belongs_to :conversion
  
  def self.get_conversions_summary promotion_id, start_date, end_date
    
    results = Hash.new
    total_data = DailySummaryAccConversion.where(promotion_id: promotion_id)
      .group(:conversion_id).select("sum(total_cv_count) as total_cv_count")
      .select("sum(first_cv_count) as first_cv_count")
      .select("sum(repeat_cv_count) as repeat_cv_count")
      .select("sum(conversion_rate) as conversion_rate")
      .select("sum(click_per_action) as click_per_action")
      .select("sum(assist_count) as assist_count")
      .select("sum(sales) as sales")
      .select("sum(roas) as roas")
      .select("sum(profit) as profit")
      .select("sum(roi) as roi")
      .select(:conversion_id)
      .where("DATE_FORMAT(daily_summary_acc_conversions.report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
      
    begin
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table2")
      connection.execute("CREATE TEMPORARY TABLE table2 (SELECT account_id, media_category_id FROM daily_summary_accounts group by media_category_id, account_id)")
      category_data = total_data.joins("left join table2 on table2.account_id = daily_summary_acc_conversions.account_id")
        .select("table2.media_category_id")
        .group("table2.media_category_id")
      category_data.each do |data|
        results[Settings.media_category[data.media_category_id]+ "_conversion" + data.conversion_id.to_s + "_total"] = data
      end
    ensure
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table2")
    end
    
    all_data = total_data.group(:account_id)
      .select(:account_id)
      
    all_data.each do |data|
      results["account"+data.account_id.to_s+"_conversion"+data.conversion_id.to_s] = data
    end
    
    total_data.each do |data|
      results["total"+"_conversion"+data.conversion_id.to_s] = data
    end
    
    results
  end
end