class UsersController < ApplicationController
  def index
    @users = User.all  
  end

  def show
  end

  def get_users_list
    @users = User.all
    @rows = Array.new
    @users.each do |user|
      @rows << {"id" => user.id, "cell" => {"roman_name" => user.roman_name, "username" => user.username, "company" => user.company, "email" => user.email, "role_id" => user.role_id}}
    end
    @data = {"page" => 1, "total" => 1, "rows" =>@rows}
  end
end
