class RemoveIndexToClients < ActiveRecord::Migration
  def change
    remove_index :clients, :column => :tel
  end

end
