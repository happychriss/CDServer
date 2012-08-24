class UploadRenameColumnFilename < ActiveRecord::Migration
  def up
    rename_column :uploads, :filename, :original_filename
  end

  def down
    rename_column :uploads, :original_filename, :filename
  end
end


