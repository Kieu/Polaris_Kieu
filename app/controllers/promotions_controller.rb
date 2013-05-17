class PromotionsController < ApplicationController
  def index
    @promotions = Promotion.all
  end

  # display dashboard screen
  def show
    #@promotion = Promotion.find(params[:id])

	aryCategory = ['2013/05/02', '2013/05/03', '2013/05/04', '2013/05/05', 
					'2013/05/06', '2013/05/07', '2013/05/08', '2013/05/09', 
					'2013/05/10', '2013/05/11', '2013/05/12', '2013/05/13']
=begin
    aryCategory = ['05/02', '05/03', '05/04', '05/05', 
					'05/06', '05/07', '05/08', '05/09', 
					'05/10', '05/11', '05/12', '05/13']
=end
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
    f.series(:type=> 'spline',:name=> 'Clicks', :data=> [300, 200, 300, 0, 500, 350, 250, 270, 280, 260, 262, 265], :color => '#008B8B')
	f.series(:type=> 'spline',:name=> 'Imp', :data=> [200, 0, 200, 500, 400, 450, 420, 350, 240, 230, 211, 245], :color => '#FFA500')
	f.legend(:align => "right", :verticalAlign => "top", :y => 0, :x => -50, :layout => 'vertical', :borderWidth => 0)
	f.xAxis( :type => 'date',
			 :dateTimeLabelFormats => {day: '%e. %b',
									   month: '%e. %b'},
			#:categories => ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
			:categories => aryCategory,
			:labels => {rotation: -45, :style => {:color => '#6D869F', :font => '12px Helvetical'}},
			)
	f.yAxis(:min => 0, :title => '')
	end
  end

  def new
    @promotion = Promotion.new
    @clients = Client.all
  end

  def edit
    @promotion = Promotion.find(params[:id])
    @clients = Client.all
  end

  def create
    @promotion = Promotion.new(params[:promotion])
    @promotion.create_usr_id = current_user.id
    if @promotion.save
      flash[:success] = "Promotion was successfully created"
      redirect_to @promotion
    else
      render :new
    end
  end

  def update
    @promotion = Promotion.find(params[:id])
    @promotion.update_usr_id = current_user_id
    if @promotion.update_attributes(params[:promotion])
      flash[:success] = "Promotion was successfully updated"
      redirect_to @promotion
    else
      render :edit
    end
  end

  def destroy
    @promotion = Promotion.find(params[:id])
    @promotion.destroy
    redirect_to promotions_path
  end
  
  def search
    if params[:q].blank?
      render :text => ""
      return
    end
    params[:q].gsub!(/'/,'')
    @search = Promotion.search do 
	  fulltext params[:q]
	end
    lines = @search.results.collect do |item|
      puts item
      "#{escape_javascript(item['promotion_name'])}#!##{item['id']}#!##{item['promotion_name']}#!##{item['promotion_name']}#!##{escape_javascript(item['promotion_name'])}"
    end
    if @search.results.count > 0
      render :text => lines.join("\n")
    else
      render text: "test#!#0#!#test#!#test#!#test"
	end
  end
end
