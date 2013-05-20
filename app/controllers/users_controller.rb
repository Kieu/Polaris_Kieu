class UsersController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super
  
  def index
  end

  def show
  end

  def get_users_list
    rp = (params[:rp]).to_i
    rp = 10 if !rp
    #current page
    page = (params[:page]).to_i
    page = 1 if !page
    start = ((page-1) * rp).to_i
    #get total records
    count = User.where(status: 0).count
    #total pages
    total_pages = (count%rp > 0) ? (count/rp) + 1 : count/rp
    #get all Users
    @users = User.where(status: 0).order('roman_name').limit(rp).offset(start)
    @rows = Array.new
    @users.each do |user|
      link = "<a href='users/#{user.id}/edit'>Edit</a>"
      @rows << {"id" => user.id, "cell" => {"link" => link,"roman_name" => user.roman_name, 
                "username" => user.username, "company" => user.company,
                "email" => user.email, "role_id" => Role.find( user.role_id).role_name}}
    end
    @data = {"page" => page, "total" => total_pages, "rows" => @rows}
    render json: @data.to_json
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
      "#{escape_javascript(item['username'])}#!##{item['id']}#!" +
        "##{item['email']}#!##{item.role.role_name}#!#" +
        "#{escape_javascript(item['username'])}"
    end
    if @search.results.count > 0
      render :text => lines.join("\n")
    else
      render text: "test#!#0#!#test#!#test#!#test"
    end
  end
end