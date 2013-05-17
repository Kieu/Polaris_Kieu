FactoryGirl.define do
  factory :client, class: Client do
    client_name "client_test"
    roman_name "client_test"
    tel "123456"
    contract_flg 0
    contract_type 0
    person_charge "person_charge"
    person_sale "person_sale"
  end

  factory :other_client, class: Client do
    client_name "other_client"
    roman_name "other_client"
    tel "987654"
    contract_flg 0
    contract_type 0
    person_charge "person_charge"
    person_sale "person_sale"
  end
end
