class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.integer :id, limit: 11
      t.integer :media_category_id, limit: 11
      t.string :media_name, limit: 255
      t.integer :del_flg, limit: 1, default: 0
    end
  end
end
