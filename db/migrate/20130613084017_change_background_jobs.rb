class ChangeBackgroundJobs < ActiveRecord::Migration
  def change
    remove_column :background_jobs, :controller
    add_column :background_jobs, :filepath, :string
  end
end
