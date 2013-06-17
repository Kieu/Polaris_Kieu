class RedirectUrl < ActiveRecord::Base
  attr_accessible :mpv, :url, :rate, :name

  def self.get_url_data promotion_id, account_id, media_id, current_page, row_per_page, start_date, end_date, type = 'index'
	# get url infomation
	current_record = (current_page.to_i - 1) * (row_per_page.to_i)
  if type == 'download'
    limit_string = ""
  else
    limit_string = " LIMIT #{current_record}, #{row_per_page} "
  end
  
	sql = "
	    SELECT 
              camp.name as campaign_name
              ,d_group.name as group_name
              ,ad.name as ad_name
              ,ad.id as ad_id
              ,camp.id as camp_id
              ,d_group.id as group_id
              ,r_url.id as redirect_url_id
              ,r_url.url as url
              ,r_url.name as url_name
              ,creative.image as creative
              ,creative.text as creative_text
              ,creative.display_type as creative_type
              ,DATE_FORMAT(r_url.update_at, '%Y/%m/%d %h:%i:%s') as last_modified
            FROM  redirect_urls as r_url
              inner join redirect_infomations as r_info
                   on r_info.mpv = r_url.mpv
              inner join display_campaigns as camp on camp.id = r_info.campaign_id
              inner join display_groups as d_group on d_group.id = r_info.group_id
              inner join display_ads as ad on ad.id = r_info.unit_id
              inner join creatives as creative on creative.id = r_info.creative_id
            WHERE
              r_info.promotion_id = #{promotion_id}
              and r_info.account_id = #{account_id}
              and r_info.media_id = #{media_id}
              and DATE_FORMAT(r_url.create_at, '%Y/%m/%d') between DATE_FORMAT('#{start_date}', '%Y/%m/%d')
                                     and DATE_FORMAT('#{end_date}', '%Y/%m/%d')
            GROUP BY r_url.url , camp.id, d_group.id, ad.id
            ORDER BY ad.name, camp.name, d_group.name
	"
  sql = sql + limit_string
	result = ActiveRecord::Base.connection.select_all(sql)

	return result
  end
end
