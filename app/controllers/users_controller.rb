class UsersController < ApplicationController
  before_filter :signed_in_user
  before_filter :must_super
  
  def index
  end

  def show
  end

  def get_users_list
    rows = get_rows(User.order_by_roman_name.page(params[:page]).per(params[:rp]))
    render json: {page: params[:page], total: User.where(status: 0).count, rows: rows}
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

  private
  def get_rows users
    rows = Array.new
    users.each do |user|
      link = "<a href='users/#{user.id}/edit'>Edit</a>"
      rows << {"id" => user.id, "cell" => {"link" => link,"roman_name" => user.roman_name, 
                "username" => user.username, "company" => user.company,
                "email" => user.email, "role_id" => user.role.role_name}}
    end
    rows
  end
end
