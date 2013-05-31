class DailySummaryAccount < ActiveRecord::Base
  attr_accessible :promotion_id, :media_category_id, :cost_per_click, :account_id, :media_id, :imp_count, :click_count, :cost_sum, :click_through_ratio, :report_ymd, :create_time


  def self.get_promotion_data(promotion_id, start_date, end_date)
  	# get promotion data
    promotion_data = Array.new
    promotion_data = self.where(promotion_id: promotion_id).where(report_ymd: (start_date)..(end_date))
          .group(:account_id, :report_ymd)
          .select(" report_ymd
  	                ,account_id
                    ,sum(cost_per_click) as cost_per_click
                    ,sum(click_through_ratio) as click_through_ratio
  	                ,sum(imp_count) as imp_count
  	                ,sum(click_count) as click_count
  	                ,sum(cost_sum) as cost_sum ")
          .order(:promotion_id)

    result = Hash.new
    promotion_data.each do |promotion|
      if(!result[promotion[:account_id]])
        result[promotion[:account_id]] = Hash.new
      end

      result.merge!(promotion[:account_id] => promotion)
    end
    
    # get conversion data
  	conversion_data = Array.new
    conversion_data = DailySummaryAccConversion.where(promotion_id: promotion_id).where(report_ymd: (start_date)..(end_date))
          .group(:conversion_id, :account_id, :report_ymd)
          .select(" report_ymd
  	                ,conversion_id
  	                ,account_id 
  	                ,sum(total_cv_count) as total_cv_count
  	                ,sum(first_cv_count) as first_cv_count
  	                ,sum(repeat_cv_count) as repeat_cv_count
  	                ,sum(assist_count)  as assist_count
  	                ,sum(sales) as sales
  	                ,sum(roas) as roas
  	                ,sum(profit) as profit
  	                ,sum(roi) as roi ")
          .order(:promotion_id)

    conversion_result = Array.new
    conversion_data.each do |conversion|
      if(!conversion_result[conversion[:account_id]])
        conversion_result[conversion[:account_id]] = Array.new
      end

      if(!conversion_result[conversion[:account_id]][conversion[:conversion_id]])
        conversion_result[conversion[:account_id]][conversion[:conversion_id]] = Array.new
      end

      conversion_result[conversion[:account_id]][conversion[:conversion_id]] = conversion
    end

    # make array result
    array_result = Hash.new
    date_range = Array.new
    (start_date.to_date..end_date.to_date).each do |date|
      date_range << date.to_date.strftime("%Y/%m/%d")
    end

    array_result['click'] = Array.new
    array_result['imp'] = Array.new
    array_result['ctr'] = Array.new
    array_result['cpc'] = Array.new
    array_result['cost'] = Array.new
    date_range.each do |datetime|
      result.each do |k, val|
        if(val[:report_ymd] && val[:report_ymd].to_s.to_date.strftime("%Y/%m/%d") == datetime)
          array_result['click'] << val[:click_count] ? val[:click_count] : 0
          array_result['imp'] << val[:imp_count] ? val[:imp_count] : 0
          array_result['ctr'] << val[:click_through_ratio] ? val[:click_through_ratio] : 0
          array_result['cpc'] << val[:cost_per_click] ? val[:cost_per_click] : 0
          array_result['cost'] << val[:cost_sum] ? val[:cost_sum] : 0
        else
          array_result['click'] << 0
          array_result['imp'] << 0
          array_result['ctr'] << 0
          array_result['cpc'] << 0
          array_result['cost'] << 0
        end
      end
    end

    return array_result, date_range
  end
end

