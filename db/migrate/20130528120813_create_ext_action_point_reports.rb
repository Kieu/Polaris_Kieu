class CreateExtActionPointReports < ActiveRecord::Migration
  def change
    create_table :ext_action_point_reports do |t|

      t.timestamps
    end
  end
end
