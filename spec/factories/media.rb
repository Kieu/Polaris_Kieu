# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :medium, :class => 'Media' do
    media_category_id "1"
    media_name "media1"
    del_flg "0"
  end
end
