class AddContentToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :content, :text
  end
end
