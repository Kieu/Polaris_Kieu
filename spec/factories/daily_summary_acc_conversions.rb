# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :daily_summary_acc_conversion do
    id ""
    promotion_id ""
    account_id ""
    conversion_id ""
    total_cv_count ""
    first_cv_count ""
    repeat_cv_count ""
    conversion_rate ""
    click_per_action ""
    assist_count ""
    sales ""
    roas ""
    profit ""
    roi 1.5
    create_time "2013-05-29 11:49:47"
    update_time "2013-05-29 11:49:47"
  end
end
