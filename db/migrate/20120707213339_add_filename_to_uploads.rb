class AddFilenameToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :filename, :string
    add_column :uploads, :source, :string
  end
end
