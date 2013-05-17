FactoryGirl.define do
  factory :role_with_super, class: Role do
    role_name "Super"
  end
  factory :role_with_no_super, class: Role do
    role_name "nosuper"
  end
  factory :role_with_agency, class: Role do
    role_name "Agency"
  end
  factory :role_with_client, class: Role do
    role_name "Client"
  end
end