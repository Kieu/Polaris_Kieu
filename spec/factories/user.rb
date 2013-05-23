FactoryGirl.define do
  factory :user, class: User do
    username "user_test"
    password "123456"
    email "user@example.com"
    roman_name "user_test"
    company_id 1
    role_id 1
    password_flg 1
  end
end
