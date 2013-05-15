namespace :master do
  desc "Create role"
  task create_role: :environment do
    Role.destroy_all
    Role.create!({id: 1, role_name: "Super", status: 0}, without_protection: true)
    Role.create!({id: 2, role_name: "Client", status: 0}, without_protection: true)
    Role.create!({id: 3, role_name: "Agency", status: 0}, without_protection: true)
  end
  
  desc "Create super user"
  task create_super_user: :environment do
    User.find_by_id(1).destroy if User.find_by_id(1)
    User.create!({id: 1, email: "example@septeni.com", username: "example",
			password: "123456789", role_id: 1, status: 0}, without_protection: true)
  end
end
