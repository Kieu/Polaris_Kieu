class DailySummaryAccount < ActiveRecord::Base
  attr_accessible :promotion_id, :media_category_id, :cost_per_click,
    :account_id, :media_id, :imp_count, :click_count, :cost_sum,
    :click_through_ratio, :report_ymd, :create_time, :cost_per_mille


  def self.get_promotion_data(promotion_id, start_date, end_date)
  	# get promotion data
    promotion_data = Array.new
    promotion_data = self.where(promotion_id: promotion_id).group(:report_ymd)
      .select(:report_ymd)
      .select(:account_id)
      .select("sum(cost_per_click) as cost_per_click")
      .select("sum(cost_per_mille) as cost_per_mille")
      .select("sum(click_through_ratio) as click_through_ratio")
      .select("sum(imp_count) as imp_count")
      .select("sum(click_count) as click_count")
      .select("sum(cost_sum) as cost_sum")
      .order(:promotion_id).where("DATE_FORMAT(report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
    
    # get conversion data
  	conversion_data = Array.new
    conversion_data = DailySummaryAccConversion
      .where(promotion_id: promotion_id)
      .group(:conversion_id, :report_ymd)
      .select(:report_ymd).select(:conversion_id).select(:account_id)
      .select("sum(total_cv_count) as total_cv_count")
      .select("sum(first_cv_count) as first_cv_count")
      .select("sum(repeat_cv_count) as repeat_cv_count")
      .select("sum(conversion_rate) as conversion_rate")
  	  .select("sum(assist_count)  as assist_count")
      .select("sum(sales) as sales")
      .select("sum(roas) as roas")
      .select("sum(profit) as profit")
      .select("sum(roi) as roi ")
      .order(:promotion_id)

    # make array result
    array_result = Hash.new
    date_range = Array.new
    (start_date.to_date..end_date.to_date).each do |date|
      date_range << date.to_date.strftime("%Y/%m/%d")
    end

    array_result['click'] = Array.new
    array_result['imp'] = Array.new
    array_result['CTR'] = Array.new
    array_result['CPC'] = Array.new
    array_result['COST'] = Array.new
    array_result['CPM'] = Array.new

    date_range.each do |datetime|
      if promotion_data.length == 0
        array_result['click'] << 0
        array_result['imp'] << 0
        array_result['CTR'] << 0
        array_result['CPC'] << 0
        array_result['COST'] << 0
        array_result['CPM'] << 0
      end
      promotion_data.each do |val|
        if(val[:report_ymd] && val[:report_ymd].to_s.to_date.strftime("%Y/%m/%d") == datetime)
          array_result['click'] << val[:click_count] ? val[:click_count] : 0
          array_result['imp'] << val[:imp_count] ? val[:imp_count] : 0
          array_result['CTR'] << val[:click_through_ratio] ? val[:click_through_ratio] : 0
          array_result['CPC'] << val[:cost_per_click] ? val[:cost_per_click] : 0
          array_result['COST'] << val[:cost_sum] ? val[:cost_sum] : 0
          array_result['CPM'] << val[:cost_per_mille] ? val[:cost_per_mille] : 0
        else
          array_result['click'] << 0
          array_result['imp'] << 0
          array_result['CTR'] << 0
          array_result['CPC'] << 0
          array_result['COST'] << 0
          array_result['CPM'] << 0
        end
      end

      conversion_data.each do |conversion|
        conversion_id = conversion[:conversion_id]

        if(!array_result["#{conversion_id}_CV"])
          array_result["#{conversion_id}_CV"] = Array.new
          array_result["#{conversion_id}_CV_First"] = Array.new
          array_result["#{conversion_id}_CV_Repeat"] = Array.new
          array_result["#{conversion_id}_CVR"] = Array.new
          array_result["#{conversion_id}_CPA"] = Array.new
          array_result["#{conversion_id}_ASSIT"] = Array.new
        end

        if(conversion[:report_ymd] && conversion[:report_ymd].to_s.to_date.strftime("%Y/%m/%d") == datetime)
          array_result["#{conversion[:conversion_id]}_CV"] << conversion[:total_cv_count] ? conversion[:total_cv_count] : 0
          array_result["#{conversion[:conversion_id]}_CV_First"] << conversion[:first_cv_count] ? conversion[:first_cv_count] : 0
          array_result["#{conversion[:conversion_id]}_CV_Repeat"] << conversion[:repeat_cv_count] ? conversion[:repeat_cv_count] : 0
          array_result["#{conversion[:conversion_id]}_CVR"] << conversion[:conversion_rate] ? conversion[:conversion_rate] : 0
          array_result["#{conversion[:conversion_id]}_CPA"] << conversion[:first_cv_count] ? conversion[:first_cv_count] : 0
          array_result["#{conversion[:conversion_id]}_ASSIT"] << conversion[:assist_count] ? conversion[:assist_count] : 0
        else
          array_result["#{conversion[:conversion_id]}_CV"] << 0
          array_result["#{conversion[:conversion_id]}_CV_First"] << 0
          array_result["#{conversion[:conversion_id]}_CV_Repeat"] << 0
          array_result["#{conversion[:conversion_id]}_CVR"] << 0
          array_result["#{conversion[:conversion_id]}_CPA"] << 0
          array_result["#{conversion[:conversion_id]}_ASSIT"] << 0
        end
      end
    end

    return array_result, date_range
  end
  
  def self.get_promotion_summary promotion_id, start_date, end_date
    results = Hash.new
    total_data = DailySummaryAccount.where(promotion_id: promotion_id)
      .where("DATE_FORMAT(report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
      .select("sum(imp_count) as imp_count")
      .select("sum(click_count) as click_count")
      .select("format((click_count/imp_count)*100,3) as click_through_ratio")
      .select("sum(cost_sum) as cost_sum")
      .select("format((cost_sum/click_count),3) as cost_per_click")
      .select("format((cost_sum/imp_count)*1000,3) as cost_per_mille")
      
    category_data = total_data.group(:media_category_id)
      .select(:media_category_id)
      
    all_data = total_data.group(:account_id).select(:account_id)
    
    category_data.each do |data|
      results[Settings.media_category[data.media_category_id]+"_total"] = data
    end
      
    all_data.each do |data|
      results["account"+data.account_id.to_s+"_promotion"] = data
    end
    results["total"] = total_data[0]
    results
  end
end