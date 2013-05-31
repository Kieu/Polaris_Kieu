class AddDelFlgToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :del_flg, :integer, default: 0
  end
end
