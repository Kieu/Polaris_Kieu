class AddColumnToBackgroundJobs < ActiveRecord::Migration
  def change
  	add_column :background_jobs, :controller, :string, limit: 256, default: nil
  end
end
