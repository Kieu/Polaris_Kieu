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
    array_result = Hash.new
      
    total_promotion_data = DailySummaryAccount.where(promotion_id: promotion_id)
      .where("DATE_FORMAT(report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
      .select("sum(imp_count) as imp_count")
      .select("sum(click_count) as click_count")
      .select("round(sum(click_count)/sum(imp_count)*100,3) as click_through_ratio")
      .select("sum(cost_sum) as cost_sum")
      .select("round(sum(cost_sum)/sum(click_count),3) as cost_per_click")
      .select("round(sum(cost_sum)/sum(imp_count)*1000,3) as cost_per_mille")
      .select(:media_category_id)
      
    category_promotion_data = total_promotion_data.group(:media_category_id)
    
    promotion_data = total_promotion_data.group(:account_id).select(:account_id)
    
    chart_promotion_data = total_promotion_data.select(:report_ymd).group(:report_ymd) 
    
    total_conversions_data = DailySummaryAccConversion.where(promotion_id: promotion_id)
      .group(:conversion_id).select("sum(total_cv_count) as total_cv_count")
      .select("sum(first_cv_count) as first_cv_count")
      .select("sum(repeat_cv_count) as repeat_cv_count")
      .select("sum(assist_count) as assist_count")
      .select("sum(sales) as sales")
      .select("sum(profit) as profit")
      .select(:conversion_id)
      .where("DATE_FORMAT(daily_summary_acc_conversions.report_ymd, '%Y/%m/%d') between '#{start_date}' and '#{end_date}'")
      .select(:report_ymd)
      
    conversions_data = total_conversions_data.group(:account_id).select(:account_id)
    
      
    begin
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table1")
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table2")
      connection.execute("CREATE TEMPORARY TABLE table1 (" + conversions_data.to_sql + ")")
      connection.execute("CREATE TEMPORARY TABLE table2 (" + promotion_data.to_sql + ")")
      
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table3")
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table4")
      connection.execute("CREATE TEMPORARY TABLE table3 (" + total_promotion_data.to_sql + ")")
      connection.execute("CREATE TEMPORARY TABLE table4 (" + total_conversions_data.to_sql + ")")
      
      promotion_conversions_data = ActiveRecord::Base.connection.select_all("select table1.account_id, table1.conversion_id, " +
        "table1.total_cv_count, table1.first_cv_count, table1.repeat_cv_count, " +
        "table1.assist_count, table1.sales, table1.profit, " +
        "round(total_cv_count/click_count*100,1) as conversion_rate, " +
        " round(cost_sum/total_cv_count,3) as click_per_action, round(sales/cost_sum*100,3) as roas, round((profit-cost_sum)/cost_sum*100,3) as roi" +
        " from table1 left join table2 on table1.account_id=table2.account_id")

      connection.execute("DROP TEMPORARY TABLE IF EXISTS table5")
      connection.execute("CREATE TEMPORARY TABLE table5 (" + category_promotion_data.to_sql + ")")
      category_conversions_data = ActiveRecord::Base.connection.select_all("select table1.conversion_id, table2.media_category_id, " +
        "sum(total_cv_count) as total_cv_count, " +
        "sum(first_cv_count) as first_cv_count, " +
        "sum(repeat_cv_count) as repeat_cv_count, " +
        "sum(assist_count) as assist_count, " +
        "sum(sales) as sales, " +
        "sum(profit) as profit, " +
        "round(sum(total_cv_count)/table5.imp_count*100,1) as conversion_rate, " +
        "round(table5.cost_sum/sum(total_cv_count),3) as click_per_action, " +
        "round(sum(sales)/table5.cost_sum*100,3) as roas, " +
        "round((sum(profit)-table5.cost_sum)/table5.cost_sum*100,3) as roi " +
        " from table1 left join table2 on table1.account_id=table2.account_id left join table5 on table5.media_category_id=table2.media_category_id  " +
        " group by table1.conversion_id, table2.media_category_id")
      
      total_conversions = ActiveRecord::Base.connection.select_all("select table4.conversion_id, " +
        "round(total_cv_count/click_count*100,1) as conversion_rate, " +
        "round(cost_sum/total_cv_count,3) as click_per_action, " +
        "round(sales/cost_sum*100,3) as roas, " +
        "round((profit-cost_sum)/cost_sum*100,3) as roi, " +
        "total_cv_count, " +
        "first_cv_count, " +
        "repeat_cv_count, " +
        "assist_count, " +
        "sales, " +
        "profit" +
        " from table3 join table4")
        
      # chart_conversions_data = ActiveRecord::Base.connection.select_all("select sum(first_cv_count) as first_cv_count, " +
        # "sum(total_cv_count) as total_cv_count, " +
        # "sum(repeat_cv_count) as repeat_cv_count, " +
        # "sum(assist_count) as assist_count, " +
        # "sum(sales) as sales, " +
        # "sum(profit) as profit, " +
        # "table1. conversion_id, " +
        # "table1.report_ymd, " +
        # "round(sum(total_cv_count)/sum(click_count)*100,1) as conversion_rate, " +
        # "round(sum(cost_sum)/sum(total_cv_count),3) as click_per_action, " +
        # "round(sum(sales)/sum(cost_sum)*100,3) as roas, " +
        # "round((sum(profit)-sum(cost_sum))/sum(cost_sum)*100,3) as roi" +
        # " from table1 left join table2 on table1.account_id=table2.account_id" +
        # " group by table1.conversion_id," +
        # " table1.report_ymd")
            
      promotion_conversions_data.each do |data|
        results["account"+data["account_id"].to_s+"_conversion" + data["conversion_id"].to_s] = data
      end
      
      promotion_data.each do |data|
        results["account"+ data.account_id.to_s + "_promotion"] = data
      end
      
      category_conversions_data.each do |data|
        results[Settings.media_category[data["media_category_id"]]+ "_conversion" + data["conversion_id"].to_s+ "_total"] = data
      end
      
      category_promotion_data.each do |data|
        results[Settings.media_category[data["media_category_id"]] + "_total"] = data
      end
      
      results["total_promotion"] = total_promotion_data[0]
      
      total_conversions.each do |data|
        results["total_conversion" + data["conversion_id"].to_s] = data
      end
      
      results["total_promotion"] = total_promotion_data[0]
     
      date_range = Array.new
      (start_date.to_date..end_date.to_date).each do |date|
        date_range << date.to_date.strftime("%Y/%m/%d")
      end
      
      Settings.promotions_options.each do |option|
        array_result[option] = Array.new  
      end
  
      # date_range.each do |datetime|
        # if chart_promotion_data.length == 0
          # Settings.promotions_options.each do |option|
            # array_result[option] << 0  
          # end
        # end
        # chart_promotion_data.each do |val|
          # if(val["report_ymd"] && val["report_ymd"].to_s.to_date.strftime("%Y/%m/%d") == datetime)
            # Settings.promotions_options.each_with_index do |option, index|
              # array_result[option] << val[Settings.promotions_sums[index]] ? val[Settings.promotions_sums[index]] : 0
            # end
          # else
            # Settings.promotions_options.each_with_index do |option, index|
              # array_result[option] << 0
            # end
          # end
        # end
#         
#         
        # chart_conversions_data.each do |conversion|
          # conversion_id = conversion["conversion_id"]
#           
          # Settings.conversions_graph.each do |option|
            # array_result["#{conversion_id}_#{option}"] = Array.new
          # end
#   
          # if(conversion[:report_ymd] && conversion[:report_ymd].to_s.to_date.strftime("%Y/%m/%d") == datetime)
            # array_result["#{conversion[:conversion_id]}_CV"] << conversion[:total_cv_count] ? conversion[:total_cv_count] : 0
            # array_result["#{conversion[:conversion_id]}_CV(first)"] << conversion[:first_cv_count] ? conversion[:first_cv_count] : 0
            # array_result["#{conversion[:conversion_id]}_CV(repeat)"] << conversion[:repeat_cv_count] ? conversion[:repeat_cv_count] : 0
            # array_result["#{conversion[:conversion_id]}_CVR"] << conversion[:conversion_rate] ? conversion[:conversion_rate] : 0
            # array_result["#{conversion[:conversion_id]}_CPA"] << conversion[:first_cv_count] ? conversion[:first_cv_count] : 0
            # array_result["#{conversion[:conversion_id]}_ASSIST"] << conversion[:assist_count] ? conversion[:assist_count] : 0
          # else
            # array_result["#{conversion[:conversion_id]}_CV"] << 0
            # array_result["#{conversion[:conversion_id]}_CV(first)"] << 0
            # array_result["#{conversion[:conversion_id]}_CV(repeat)"] << 0
            # array_result["#{conversion[:conversion_id]}_CVR"] << 0
            # array_result["#{conversion[:conversion_id]}_CPA"] << 0
            # array_result["#{conversion[:conversion_id]}_ASSIST"] << 0
          # end
        # end
      # end
    ensure
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table1")
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table2")
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table3")
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table4")
      connection.execute("DROP TEMPORARY TABLE IF EXISTS table5")
    end
    
    results
  end
end