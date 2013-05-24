# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :press_release do
    content "MyText"
    release_time "2013-05-23 17:39:21"
    create_user_id 1
    update_user_id 1
  end
end
