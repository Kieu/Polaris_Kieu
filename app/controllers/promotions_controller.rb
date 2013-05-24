class PromotionsController < ApplicationController
  before_filter :signed_in_user

  def index
  	if(current_user.role_id == Settings.role.CLIENT)
  		clientId = current_user.company_id
  	elsif
  		clientId = params[:clientId]
  	end

  	@aryPromotion = Promotion.where("client_id = ? ", clientId).order('promotion_name')

    #display highchart
    #@promotion = Promotion.find(params[:id])
=begin
    aryCategory = ['2013/05/02', '2013/05/03', '2013/05/04', '2013/05/05', 
          '2013/05/06', '2013/05/07', '2013/05/08', '2013/05/09', 
          '2013/05/10', '2013/05/11', '2013/05/12', '2013/05/13']
=end
    aryCategory = ['05/02', '05/03', '05/04', '05/05', 
          '05/06', '05/07', '05/08', '05/09', 
          '05/10', '05/11', '05/12', '05/13']

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

  def show
  end
end