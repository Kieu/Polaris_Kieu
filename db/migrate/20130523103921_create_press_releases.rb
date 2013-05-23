class CreatePressReleases < ActiveRecord::Migration
  def change
    create_table :press_releases do |t|
      t.text :content
      t.datetime :release_time
      t.integer :create_user_id
      t.integer :update_user_id

      t.timestamps
    end
  end
end
