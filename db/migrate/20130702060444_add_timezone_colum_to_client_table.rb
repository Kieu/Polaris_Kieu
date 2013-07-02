class AddTimezoneColumToClientTable < ActiveRecord::Migration
  def change
    add_column :clients, :time_zone, "char(3)", :after => 'person_sale'
  end
end
