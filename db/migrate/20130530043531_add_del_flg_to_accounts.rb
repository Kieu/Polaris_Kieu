class AddDelFlgToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :del_flg, :string,limit 1, default: 0
  end
end
