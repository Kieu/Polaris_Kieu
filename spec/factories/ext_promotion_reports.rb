# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ext_promotion_report do
    promotion_id 1
    media_category_id 1
    media_id ""
    account_id 1
    imp 1
    click 1
    cost 1
    report_date "2013-05-28"
  end
end
