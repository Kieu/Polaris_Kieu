class Conversion < ActiveRecord::Base
  attr_accessible :conversion_category, :conversion_combine, :conversion_mode,
    :conversion_name, :duplicate, :facebook_app_id, :judging, :os, :reward_form,
    :roman_name, :sale_unit_price, :session_period, :start_point, :track_method,
    :track_type, :unique_def, :url

  belongs_to :promotion

  validates :conversion_name, presence: true, uniqueness: {scope: :promotion_id}
  validates :roman_name, presence: true, uniqueness: {scope: :promotion_id}
  validates :conversion_category, presence: true
  validates :track_type, presence: true, if: :check_app
  validates :session_period, presence: true, if: :check_track_type
  validates :unique_def, presence: true, if: :check_conversion_category
  validates :os, presence: true, if: :check_app
  validates :conversion_mode, presence: true, if: :check_app
  validates :duplicate, presence: true, if: :check_conversion_category
  validates :track_method, presence: true, if: :check_app
  validates :facebook_app_id, presence: true, if: :check_os
  validates :start_point, presence: true, if: :check_web
  validates :conversion_combine, presence: true, if: :check_combination
  validates :url, presence: true, if: :check_track_method

  private
  def check_conversion_category
    conversion_category == 0 || conversion_category == 1
  end

  def check_web
    conversion_category == 0
  end

  def check_app
    conversion_category == 1
  end

  def check_combination
    conversion_category == 2
  end

  def check_track_type
    track_type == 1
  end

  def check_os
    os == 0
  end

  def check_track_method
    track_method == 3
  end
end
