class AddJobIdToBackgroundJobs < ActiveRecord::Migration
  def change
    add_column :background_jobs, :job_id, :string
  end
end
