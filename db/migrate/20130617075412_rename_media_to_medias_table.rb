class RenameMediaToMediasTable < ActiveRecord::Migration
    def change
        rename_table :media, :medias
    end 
end
