# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :conversion_1_log, :class => 'Conversion1Logs' do
    media_category_id 1
    media_id 1
    account_id 1
    campaign_id 1
    ad_group_id 1
    ad_id 1
    conversion_id 1
    redirect_infomation_id 1
    mpv "MyString"
    redirect_url_id 1
    creative_id 1
    session_id "MyString"
    verify "MyString"
    suid "MyString"
    reqest_url ""
    redirect_url ""
    media_session_id "MyString"
    device_category "MyString"
    user_agent ""
    referrer ""
    click_referrer ""
    access_time 1
    access_vmd 1
    click_time 1
    remote_ip "MyString"
    mark "MyString"
    conversion_category "MyString"
    conversion_type "MyString"
    repeat_flg "MyString"
  end
end
