FactoryGirl.define do
  factory :client_user, class: ClientsUser do
    client_id 1
    user_id 1
    del_flg Settings.client_user.active
  end
end
