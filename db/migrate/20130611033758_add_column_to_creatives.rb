class AddColumnToCreatives < ActiveRecord::Migration
  def change
  	add_column :creatives, :del_flg, :string, limit: 1
  	add_column :creatives, :text, :text
  	add_column :creatives, :type, :string, limit: 1
  end
end
