class CreateBackgroundJobs < ActiveRecord::Migration
  def change
    create_table :background_jobs do |t|
      t.integer :user_id, limit: 11
      t.string :filename, limit: 512
      t.string :type_view, limit: 255
      t.string :status, limit: 1

      t.timestamps
    end
  end
end
