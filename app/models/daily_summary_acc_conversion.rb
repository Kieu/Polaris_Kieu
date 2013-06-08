class DailySummaryAccConversion < ActiveRecord::Base
  attr_accessible :report_ymd, :account_id, :assist_count, :click_per_action,
    :conversion_id, :conversion_rate, :create_time, :first_cv_count, :id,
    :profit, :promotion_id, :repeat_cv_count, :roas, :roi, :sales,
    :total_cv_count, :update_time

  belongs_to :account
  belongs_to :conversion
  
  def self.get_conversions_summary promotion_id, start_date, end_date
    
    results = Hash.new
    total_data = DailySummaryAccConversion.where(promotion_id: promotion_id)
      .group(:conversion_id).select("sum(total_cv_count) as stcc")
      .select("sum(first_cv_count) as first_cv_count")
      .select("sum(repeat_cv_count) as repeat_cv_count")
      .select("sum(conversion_rate) as conversion_rate")
      .select("sum(click_per_action) as click_per_action")
      .select("sum(assist_count) as assist_count")
      .select("sum(sales) as sales")
      .select("sum(roas) as roas")
      .select("sum(profit) as profit")
      .select("sum(roi) as roi")
      
    all_data = total_data.group(:account_id)
      .select(:account_id)
      .select(:conversion_id)
      
    conversions = Promotion.find(promotion_id).conversions
    conversions.each_with_index do |conversion|
      all_data.each do |data|
        results["account"+data.account_id.to_s+"_conversion"+data.conversion_id.to_s] = data
      end
      total_data.each do |data|
        results["total"+"_conversion"+conversion.id.to_s] = data
      end
    end
    
    results
  end
end