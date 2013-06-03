namespace :master do
  desc "Create role"
  task create_role: :environment do
    Role.destroy_all
    Role.create!({id: 1, role_name: "Super", status: 0}, without_protection: true)
    Role.create!({id: 2, role_name: "Client", status: 0}, without_protection: true)
    Role.create!({id: 3, role_name: "Agency", status: 0}, without_protection: true)
  end

  desc "Create Agency"
  task create_agency: :environment do
    Agency.destroy_all
    (1..100).each do |num|
      Agency.create!({id: num, agency_name: "agency_#{num}", roman_name: "agency_#{num}"},
        without_protection: true)
    end
  end

  desc "Create Client"
  task create_client: :environment do
    Client.destroy_all
    (1..100).each do |num|
      Client.create!({id: num, client_name: "client_#{num}", roman_name: "client_#{num}",
        tel: "#{num}#{num}#{num}#{num}", contract_flg: 1, contract_type: 1,
        person_charge: "person_#{num}", person_sale: "person_#{num}"},
        without_protection: true)
    end
  end
  
  desc "Create super user"
  task create_super_user: :environment do
    User.find_by_id(1).destroy if User.find_by_id(1)
    User.create!({id: 1, email: "super@septeni.com", username: "super",
      password: "123456789", role_id: 1, status: 0, roman_name: "super",
      company_id: 1, password_flg: 0}, without_protection: true)
  end

  desc "Create agency user"
  task create_agency_user: :environment do
    User.find_by_id(2).destroy if User.find_by_id(2)
    User.create!({id: 2, email: "agency@septeni.com", username: "agency",
      password: "123456789", role_id: 3, status: 0, roman_name: "agency",
      company_id: 1, password_flg: 0}, without_protection: true)
  end

  desc "Create client user"
  task create_client_user: :environment do
    User.find_by_id(3).destroy if User.find_by_id(3)
    User.create!({id: 3, email: "client@septeni.com", username: "client",
      password: "123456789", role_id: 2, status: 0, roman_name: "client",
      company_id: 1, password_flg: 0}, without_protection: true)
  end
  
  desc "Create Press Release"
  task create_press_release: :environment do
    (1..100).each do |num|
      PressRelease.create!(content: "test_#{num}", release_time: Time.now, create_user_id: 1)
    end
  end

  desc "Create Ext Promotion Report"
  task create_ext_promotion_report: :environment do
    (1..100).each do |num|
      ExtPromotionReport.create!(promotion_id: "#{num}", media_category_id: 1,
                                 media_id: 1, account_id: 1, imp: "#{num + 10}",
                                 click: "#{num + 15}", cost: "#{num + 30}", report_date: 20130525)
    end
  end

  desc "Create Daily Summary Account"
  task create_daily_summary_account: :environment do
    (1..100).each do |num|
      DailySummaryAccount.create!(id: "#{num}", promotion_id: 1, media_category_id: 1,
                                 media_id: 1, account_id: 1, imp_count: "#{num + 10}",
                                 click_count: "#{num + 15}", cost_sum: "#{num + 30}", report_ymd: 20130525, create_time: 20130525)
    end
  end

  desc "Create Media"
  task create_media: :environment do
    (1..100).each do |num|
      Media.create!(id: "#{num}", media_category_id: 1, media_name: "media_#{num}")
    end
  end

  desc "Create Daily Summary Acc Conversion"
  task create_daily_summary_acc_conversion: :environment do
    (1..100).each do |num|
      DailySummaryAccConversion.create!(id: "#{num}", promotion_id: 1, account_id: 1,
                                 conversion_id: 1, total_cv_count: "#{num + 50}", first_cv_count: "#{num + 35}",
                                 repeat_cv_count: "#{num + 15}", assist_count: "#{num + 12}", report_ymd: 20130525, create_time: 20130525,
                                sales: "#{num + 200}", roas: "#{num + 21}", profit: "#{num + 500}", roi: "#{num + 27}")
    end
  end
  
  desc "Create Display ads"
  task create_display_ad: :environment do
    (3..100).each do |num|
      DisplayAd.create!(id: "#{num}", identifier: "identify#{num}", name: "ad#{num}",
                                 client_id: 1, promotion_id: 1, account_id: 1,display_campaign_id: 1,
                                 display_group_id: 1, create_user_id: 1, update_user_id: 1)
    end
  end
  
  desc "Create Display group"
  task create_display_group: :environment do
    (5..100).each do |num|
      DisplayGroup.create!(id: "#{num}", name: "ad_group#{num}", client_id: 1, promotion_id: 1, account_id: 1,
       create_user_id: 1, update_user_id: 1)
    end
  end
  desc "Create Display campaign"
  task create_display_campaign: :environment do
    (5..100).each do |num|
      DisplayCampaign.create!(id: "#{num}", name: "campaign#{num}", client_id: 1, promotion_id: 1, account_id: 1, create_user_id: 1, update_user_id: 1)
    end
  end
  
end