FactoryGirl.define do
  factory :user, class: User do
    username "quan"
    password "123456"
    email "user@example.com"
    roman_name "quanhd"
    company "Septeni"
    role_id 1
    password_flg 1
    language "en"
  end
end
