namespace :master do
  desc "Create role"
  task create_role: :environment do
    Role.destroy_all
    Role.create!({id: 1, role_name: "Super", status: 0}, without_protection: true)
    Role.create!({id: 2, role_name: "Client", status: 0}, without_protection: true)
    Role.create!({id: 3, role_name: "Agency", status: 0}, without_protection: true)
  end

  desc "Create Agency"
  task create_agency: :environment do
    Agency.destroy_all
    (1..100).each do |num|
      Agency.create!({id: num, agency_name: "agency_#{num}", roman_name: "agency_#{num}"},
        without_protection: true)
    end
  end

  desc "Create Client"
  task create_client: :environment do
    Client.destroy_all
    (1..100).each do |num|
      Client.create!({id: num, client_name: "client_#{num}", roman_name: "client_#{num}",
        tel: "#{num}#{num}#{num}#{num}", contract_flg: 1, contract_type: 1,
        person_charge: "person_#{num}", person_sale: "person_#{num}"},
        without_protection: true)
    end
  end
  
  desc "Create super user"
  task create_super_user: :environment do
    User.find_by_id(1).destroy if User.find_by_id(1)
    User.create!({id: 1, email: "super@septeni.com", username: "super",
      password: "123456789", role_id: 1, status: 0, roman_name: "super",
      company_id: 1, password_flg: 0}, without_protection: true)
  end

  desc "Create agency user"
  task create_agency_user: :environment do
    User.find_by_id(2).destroy if User.find_by_id(2)
    User.create!({id: 2, email: "agency@septeni.com", username: "agency",
      password: "123456789", role_id: 3, status: 0, roman_name: "agency",
      company_id: 1, password_flg: 0}, without_protection: true)
  end

  desc "Create client user"
  task create_client_user: :environment do
    User.find_by_id(3).destroy if User.find_by_id(3)
    User.create!({id: 3, email: "client@septeni.com", username: "client",
      password: "123456789", role_id: 2, status: 0, roman_name: "client",
      company_id: 1, password_flg: 0}, without_protection: true)
  end
  
  desc "Create Press Release"
  task create_press_release: :environment do
    (1..100).each do |num|
      PressRelease.create!(content: "test_#{num}", release_time: Time.now, create_user_id: 1)
    end
  end
end