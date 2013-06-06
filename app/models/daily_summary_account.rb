class DailySummaryAccount < ActiveRecord::Base
  attr_accessible :promotion_id, :media_category_id, :cost_per_click,
    :account_id, :media_id, :imp_count, :click_count, :cost_sum,
    :click_through_ratio, :report_ymd, :create_time, :cost_per_mille


  def self.get_promotion_data(promotion_id, conversion_id, start_date, end_date)
  	# get promotion data
    promotion_data = Array.new
    promotion_data = self.where(promotion_id: promotion_id).where(report_ymd: (start_date)..(end_date))
          .group(:report_ymd)
          .select(" report_ymd
  	                ,account_id
                    ,sum(cost_per_click) as cost_per_click
                    ,sum(cost_per_mille) as cost_per_mille
                    ,sum(click_through_ratio) as click_through_ratio
  	                ,sum(imp_count) as imp_count
  	                ,sum(click_count) as click_count
  	                ,sum(cost_sum) as cost_sum ")
          .order(:promotion_id)
    
    # get conversion data
  	conversion_data = Array.new
    conversion_data = DailySummaryAccConversion.where(promotion_id: promotion_id).where(report_ymd: (start_date)..(end_date))
          .group(:conversion_id, :report_ymd)
          .select(" report_ymd
  	                ,conversion_id
  	                ,account_id 
  	                ,sum(total_cv_count) as total_cv_count
  	                ,sum(first_cv_count) as first_cv_count
  	                ,sum(repeat_cv_count) as repeat_cv_count
                    ,sum(conversion_rate) as conversion_rate
  	                ,sum(assist_count)  as assist_count
  	                ,sum(sales) as sales
  	                ,sum(roas) as roas
  	                ,sum(profit) as profit
  	                ,sum(roi) as roi ")
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
    Settings.media_category.each do |category|
      summary = DailySummaryAccount.where(promotion_id: promotion_id)
        .where(media_category_id: category[0].to_s).where(report_ymd: (start_date)..(end_date))
      Settings.promotions_sums.each_with_index do |sum, index|
        results[category[1]+"_"+Settings.promotions_options[index]+"_total"] =
          summary.sum(sum)
  
        Media.where(media_category_id: category[0].to_s)
          .each_with_index do |media, index1|
          media.accounts.each_with_index do |account, index2|
            results[account.account_name+"_"+Settings
              .promotions_options[index]] =
                summary.where(account_id: account.id).sum(sum)
          end
        end
      end
    end
    
    Settings.promotions_options.each_with_index do |option, index|
      results[option+"_total"] = 0
      Settings.media_category.each do |category|
        results[option+"_total"] += results[category[1]+"_"+option+"_total"]
      end
    end
    results
  end
end