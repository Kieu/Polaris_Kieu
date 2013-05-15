class ClientsController < ApplicationController
  def index
    @clients = Client.all
    @promotions = Promotion.all
  end

  def show
    @client = Client.find(params[:id])
  end

  def new
    @client = Client.new
  end

  def edit
    @client = Client.find(params[:id])
  end

  def create
    @client = Client.new(params[:client])
    @client.create_usr_id = current_user.id
    if @client.save
      flash[:success] = "Client was successfully created"
      redirect_to @client
    else
      render :new
    end
  end

  def update
    @client = Client.find(params[:id])
    @client.update_usr_id = current_user.id
    if @client.update_attributes(params[:client])
      flash[:success] = "Client was successfully updated"
      redirect_to @client
    else
      render :edit
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to clients_path
  end
end
