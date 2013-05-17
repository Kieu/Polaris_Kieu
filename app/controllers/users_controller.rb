class UsersController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super
  
  def index
    @users = User.all  
  end

  def show
  end

  def get_users_list
    @users = User.all
    @rows = Array.new
    @users.each do |user|
      @rows << {"id" => user.id, "cell" => {"roman_name" => user.roman_name,
        "username" => user.username, "role_id" => user.role_id}}
    end
    @data = {"page" => 1, "total" => 1, "rows" =>@rows}
  end
  
  def search
    if params[:q].blank?
      render :text => ""
      return
    end
    params[:q].gsub!(/'/,'')
    @search = User.search do
      fulltext params[:q]
    end
    lines = @search.results.collect do |item|
      puts item
      "#{escape_javascript(item['username'])}#!##{item['id']}#!##{item['email']}#!##{item.role.role_name}#!##{escape_javascript(item['username'])}"
    end
    if @search.results.count > 0
      render :text => lines.join("\n")
    else
      render text: "test#!#0#!#test#!#test#!#test"
    end
  end
end