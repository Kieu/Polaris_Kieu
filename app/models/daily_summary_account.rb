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
          array_result["#{conversion_id}_CV(first)"] = Array.new
          array_result["#{conversion_id}_CV(repeat)"] = Array.new
          array_result["#{conversion_id}_CVR"] = Array.new
          array_result["#{conversion_id}_CPA"] = Array.new
          array_result["#{conversion_id}_ASSIST"] = Array.new
        end

        if(conversion[:report_ymd] && conversion[:report_ymd].to_s.to_date.strftime("%Y/%m/%d") == datetime)
          array_result["#{conversion[:conversion_id]}_CV"] << conversion[:total_cv_count] ? conversion[:total_cv_count] : 0
          array_result["#{conversion[:conversion_id]}_CV(first)"] << conversion[:first_cv_count] ? conversion[:first_cv_count] : 0
          array_result["#{conversion[:conversion_id]}_CV(repeat)"] << conversion[:repeat_cv_count] ? conversion[:repeat_cv_count] : 0
          array_result["#{conversion[:conversion_id]}_CVR"] << conversion[:conversion_rate] ? conversion[:conversion_rate] : 0
          array_result["#{conversion[:conversion_id]}_CPA"] << conversion[:first_cv_count] ? conversion[:first_cv_count] : 0
          array_result["#{conversion[:conversion_id]}_ASSIST"] << conversion[:assist_count] ? conversion[:assist_count] : 0
        else
          array_result["#{conversion[:conversion_id]}_CV"] << 0
          array_result["#{conversion[:conversion_id]}_CV(first)"] << 0
          array_result["#{conversion[:conversion_id]}_CV(repeat)"] << 0
          array_result["#{conversion[:conversion_id]}_CVR"] << 0
          array_result["#{conversion[:conversion_id]}_CPA"] << 0
          array_result["#{conversion[:conversion_id]}_ASSIST"] << 0
        end
      end
    end

    return array_result, date_range
  end
  
  def self.get_table_data promotion_id, start_date, end_date
    results = Hash.new
    promotion_data = DailySummaryAccount.where(promotion_id: promotion_id)
      .where("DATE_FORMAT(report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
      .select("sum(imp_count) as imp_count")
      .select("sum(click_count) as click_count")
      .select("round(sum(click_count)/sum(imp_count)*100,3) as click_through_ratio")
      .select("sum(cost_sum) as cost_sum")
      .select("round(sum(cost_sum)/sum(click_count),3) as cost_per_click")
      .select("round(sum(cost_sum)/sum(imp_count)*1000,3) as cost_per_mille")
      .group(:account_id).select(:account_id).select(:media_category_id)
    
    conversions_data = DailySummaryAccConversion.where(promotion_id: promotion_id)
      .group(:conversion_id).select("sum(total_cv_count) as total_cv_count")
      .select("sum(first_cv_count) as first_cv_count")
      .select("sum(repeat_cv_count) as repeat_cv_count")
      .select("sum(assist_count) as assist_count")
      .select("sum(sales) as sales")
      .select("sum(profit) as profit")
      .select(:conversion_id)
      .where("DATE_FORMAT(daily_summary_acc_conversions.report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
      .group(:account_id)
      .select(:account_id)
      .select(:report_ymd)
    
    begin
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table1")
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table2")
      connection.execute("CREATE TEMPORARY TABLE table1 (" + conversions_data.to_sql + ")")
      connection.execute("CREATE TEMPORARY TABLE table2 (" + promotion_data.to_sql + ")")
      
      all_data = ActiveRecord::Base.connection.select_all("select *, round(total_cv_count/click_count*100,3) as conversion_rate, " +
        " round(cost_sum/total_cv_count,3) as click_per_action, round(sales/cost_sum*100,3) as roas, round((profit-cost_sum)/cost_sum*100,3) as roi" +
        " from table1 left join table2 on table1.account_id=table2.account_id")
        
      total_promotion_data = ActiveRecord::Base.connection.select_all("select sum(imp_count) as imp_count, sum(click_count) as click_count, " +
        "round(sum(click_count)/sum(imp_count)*100,3) as click_through_ratio, " +
        "sum(cost_sum) as cost_sum, " +
        "round(sum(cost_sum)/sum(click_count),3) as cost_per_click, " +
        "round(sum(cost_sum)/sum(imp_count)*1000,3) as cost_per_mille" +
        " from table1 left join table2 on table1.account_id=table2.account_id")
        
      total_conversions_data = ActiveRecord::Base.connection.select_all("select sum(first_cv_count) as first_cv_count, " +
        "sum(total_cv_count) as total_cv_count, " +
        "sum(repeat_cv_count) as repeat_cv_count, " +
        "sum(assist_count) as assist_count, " +
        "sum(sales) as sales, " +
        "sum(profit) as profit, " +
        "table1. conversion_id, " +
        "round(sum(total_cv_count)/sum(click_count)*100,3) as conversion_rate, " +
        "round(sum(cost_sum)/sum(total_cv_count),3) as click_per_action, " +
        "round(sum(sales)/sum(cost_sum)*100,3) as roas, " +
        "round((sum(profit)-sum(cost_sum))/sum(cost_sum)*100,3) as roi" +
        " from table1 left join table2 on table1.account_id=table2.account_id" +
        " group by table1.conversion_id")
        
      category_promotion_data = ActiveRecord::Base.connection.select_all("select sum(imp_count) as imp_count, sum(click_count) as click_count, " +
        "round(sum(click_count)/sum(imp_count)*100,3) as click_through_ratio, " +
        "sum(cost_sum) as cost_sum, " +
        "round(sum(cost_sum)/sum(click_count),3) as cost_per_click, " +
        "round(sum(cost_sum)/sum(imp_count)*1000,3) as cost_per_mille, " +
        "table2.media_category_id" +
        " from table1 left join table2 on table1.account_id=table2.account_id" +
        " group by table2.media_category_id")
        
      category_conversions_data = ActiveRecord::Base.connection.select_all("select sum(first_cv_count) as first_cv_count, " +
        "sum(total_cv_count) as total_cv_count, " +
        "sum(repeat_cv_count) as repeat_cv_count, " +
        "sum(assist_count) as assist_count, " +
        "sum(sales) as sales, " +
        "sum(profit) as profit, " +
        "round(sum(total_cv_count)/sum(click_count)*100,3) as conversion_rate, " +
        "round(sum(cost_sum)/sum(total_cv_count),3) as click_per_action, " +
        "round(sum(sales)/sum(cost_sum)*100,3) as roas, " +
        "round((sum(profit)-sum(cost_sum))/sum(cost_sum)*100,3) as roi, " +
        "table2.media_category_id," +
        "table1.conversion_id" +
        " from table1 left join table2 on table1.account_id=table2.account_id" +
        " group by table2.media_category_id, table1.conversion_id")
      
      all_data.each do |data|
        results["account"+data["account_id"].to_s+"_promotion"] = Array.new
        results["account"+data["account_id"].to_s+"_conversion" + data["conversion_id"].to_s] = Array.new
        Settings.promotions_sums.each do |option|
          results["account"+data["account_id"].to_s+"_promotion"] << data[option]
        end
        
        Settings.conversions_sums.each do |option|
          results["account"+data["account_id"].to_s+"_conversion" + data["conversion_id"].to_s] << data[option]
        end
      end
      
      category_promotion_data.each do |data|
        results[Settings.media_category[data["media_category_id"]]+"_total"] = data
      end
      
      category_conversions_data.each do |data|
        results[Settings.media_category[data["media_category_id"]]+ "_conversion" + data["conversion_id"].to_s+ "_total"] = data
      end
      
      results["total_promotion"] = total_promotion_data[0]
      total_conversions_data.each do |data|
        results["total_conversion"+data["conversion_id"].to_s] = data
      end
    ensure
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table1")
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table2")
    end
    
    results
  end
end