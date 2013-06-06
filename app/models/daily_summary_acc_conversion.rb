class DailySummaryAccConversion < ActiveRecord::Base
  attr_accessible :report_ymd, :account_id, :assist_count, :click_per_action,
    :conversion_id, :conversion_rate, :create_time, :first_cv_count, :id,
    :profit, :promotion_id, :repeat_cv_count, :roas, :roi, :sales,
    :total_cv_count, :update_time

  belongs_to :account
  belongs_to :conversion
  
  def self.get_conversions_summary promotion_id, start_date, end_date
    conversions = Promotion.find(promotion_id).conversions
    results = Hash.new
    conversions.each_with_index do |conversion|
      Settings.media_category.each do |category|
        summary = DailySummaryAccConversion.where(conversion_id: conversion.id).where(report_ymd: (start_date)..(end_date))
        Settings.conversions_sums.each_with_index do |sum, index|
          results[category[1]+"_conversion" + conversion.id.to_s + "_" +
            Settings.conversions_options[index]] = 0
          Media.where(media_category_id: category[0].to_s)
            .each_with_index do |media, index1|
            media.accounts.each_with_index do |account, index2|
              results[account.account_name + "_conversion" + conversion.id.to_s + 
                "_" + Settings.conversions_options[index]] =
                  summary.where(account_id: account.id).sum(sum)
              results[category[1]+"_conversion" + conversion.id.to_s + "_" +
                Settings.conversions_options[index]] +=
                  results[account.account_name + "_conversion" +
                    conversion.id.to_s + "_" + Settings.conversions_options[index]] 
            end
          end
        end
      end
    end
    
    conversions.each_with_index do |conversion|
      Settings.conversions_options.each_with_index do |option, index|
        results["conversion"+conversion.id.to_s+"_"+ option+"_total"] = 0
        Settings.media_category.each do |category|
          results["conversion"+conversion.id.to_s+"_"+ option+"_total"] +=
            results[category[1]+"_conversion"+conversion.id.to_s+"_" +option]
        end
      end
    end
    results
  end
end