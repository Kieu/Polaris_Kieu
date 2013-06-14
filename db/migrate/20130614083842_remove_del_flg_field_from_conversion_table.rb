class RemoveDelFlgFieldFromConversionTable < ActiveRecord::Migration
remove_column :conversions, :del_flg
end
