class DailySummaryAccount < ActiveRecord::Base
  attr_accessible :promotion_id, :media_category_id, :account_id, :media_id, :imp_count, :click_count, :cost_sum, :report_ymd, :create_time


  def self.get_promotion_data(promotion_id, start_date, end_date)
  	# get promotion data
    promotion_data = Array.new
    promotion_data = self.where(promotion_id: promotion_id).where(report_ymd: (start_date)..(end_date))
          .group(:promotion_id, :media_category_id, :media_id, :account_id, :report_ymd)
          .select(" report_ymd
  	                ,media_category_id
  	                ,media_id
  	                ,account_id
  	                ,sum(imp_count) as imp_count
  	                ,sum(click_count) as click_count
  	                ,sum(cost_sum) as cost_sum ")
          .order(:promotion_id)

    # get conversion data
  	conversion_data = Array.new
    conversion_data = DailySummaryAccConversion.where(promotion_id: promotion_id).where(report_ymd: (start_date)..(end_date))
          .group(:promotion_id, :conversion_id, :account_id, :report_ymd)
          .select(" report_ymd
  	                ,conversion_id
  	                ,account_id 
  	                ,sum(total_cv_count) as total_cv_count
  	                ,sum(first_cv_count) as first_cv_count
  	                ,sum(repeat_cv_count) as repeat_cv_count
  	                ,sum(assist_count as assist_count)
  	                ,sum(sales) as sales
  	                ,sum(roas) as roas
  	                ,sum(profit) as profit
  	                ,sum(roi) as roi ")
          .order(:promotion_id)
    
    

  end
end

