class Media < ActiveRecord::Base
  attr_accessible :media_category_id, :media_name, :del_flg

  has_many :accounts
  
  def self.get_media_list
    results = Hash.new
    all_media = Media.all
    Settings.media_category.each do |category|
      results[category[1]+"_media"] = Array.new
    end
    all_media.each_with_index do |media, index|
      results[Settings.media_category[media.media_category_id]+"_media"] << media 
    end
    results
  end
end