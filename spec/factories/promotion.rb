FactoryGirl.define do
  factory :promotion, class: Promotion do
    promotion_name "promotion_test"
    roman_name "promotion_test"
    promotion_category_id 1
    tracking_period 10
    client_id 1
    agency_id 1
  end
end
