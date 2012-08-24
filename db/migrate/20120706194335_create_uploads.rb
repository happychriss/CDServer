class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.text :content
      t.integer :folder_id

      t.timestamps
    end
  end
end
