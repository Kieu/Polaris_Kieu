FactoryGirl.define do
  factory :promotion, class: Promotion do
    promotion_name "promotion_test"
    promotion_category_id 1
    del_flg 0
  end
end
