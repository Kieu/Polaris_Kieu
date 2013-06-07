class AddMvToConversions < ActiveRecord::Migration
  def change
    add_column :conversions, :mv, :string
  end
end
