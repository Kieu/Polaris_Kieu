class Conversion < ActiveRecord::Base
  VALID_NUMBER_REGEX = /^\d+$/
  
  attr_accessible :conversion_category, :conversion_combine, :conversion_mode,
    :conversion_name, :duplicate, :facebook_app_id, :judging, :os, :reward_form,
    :roman_name, :sale_unit_price, :session_period, :start_point, :track_method,
    :track_type, :unique_def, :url

  belongs_to :promotion

  validates :conversion_name, presence: true, uniqueness: {scope: :promotion_id}
  validates :roman_name, presence: true, uniqueness: {scope: :promotion_id}
  validates :conversion_category, presence: true
  validates :track_type, presence: true, if: :check_app
  validates_inclusion_of :session_period, :in => 1..90, if: :check_track_type1
  validates :unique_def, presence: true, if: :check_conversion_category
  validates :os, presence: true, if: :check_track_type
  validates :conversion_mode, presence: true, if: :check_track_type
  validates :duplicate, presence: true, if: :check_track_type
  validates :track_method, presence: true, if: :check_track_type
  validates :facebook_app_id, :numericality => { :only_integer => true}, presence: true , if: :check_fb_id_valid
  validates :start_point, presence: true, if: :check_web
  validates :conversion_combine, presence: true, if: :check_combination
  validates :url, length: {maximum: 255}, presence: true, if: :check_track_method
  validates :sale_unit_price, length: {maximum: 10}, :numericality => { :only_integer => true}, if: :check_sales?
  # validates_inclusion_of :sale_unit_price, :in => 1..2147483647, if: :check_sales?, if: -> conversion { conversion.sale_unit_price.is_a? Integer)
  scope :order_by_conversion_name, ->{order :conversion_name}
  scope :order_by_id, ->{order :id}
  scope :get_by_promotion_id, lambda {|promotion_id| where(promotion_id: promotion_id)}
  def create_mv
    mv = ""
    if (client_id = self.promotion.client.id.to_s(36)).length < 8
      mv << "0" * (8 - client_id.length) << client_id
    end
    if (promotion_id = self.promotion.id.to_s(36)).length < 8
      mv << "0" * (8 - promotion_id.length) << promotion_id
    end
    if (conversion_id = self.id.to_s(36)).length < 8
      mv << "0" * (8 - conversion_id.length) << conversion_id
    end
    mv << SecureRandom.urlsafe_base64(6)
    mv = Digest::MD5::hexdigest(mv)
    self.update_attribute(:mv, mv)
  end

  private
  def check_conversion_category
    conversion_category.to_i == 1 || conversion_category.to_i == 2
  end

  def check_web
    conversion_category.to_i == 1
  end

  def check_app
    conversion_category.to_i == 2
  end

  def check_combination
    conversion_category.to_i == 3
  end

  def check_track_type
    track_type.to_i == 1
  end

  def check_track_type1
    conversion_category.to_i == 2 && track_type.to_i == 2
  end

  def check_track_method
    track_method.to_i == 3
  end

  def check_conversion_mode
    conversion_mode.to_i == 2
  end
  
  def check_fb_id_valid
    conversion_category.to_i == 2 && track_type.to_i == 1 && conversion_mode.to_i != 2
  end
  
  def check_sales?
    !sale_unit_price.blank? 
  end

end
