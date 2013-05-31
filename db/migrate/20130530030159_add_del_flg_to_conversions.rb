class AddDelFlgToConversions < ActiveRecord::Migration
  def change
    add_column :conversions, :del_flg, :integer, default: 0
  end
end
