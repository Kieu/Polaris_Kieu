class ChangeBackgroundJobs < ActiveRecord::Migration
  def change
    add_column :background_jobs, :filepath, :string
  end
end
