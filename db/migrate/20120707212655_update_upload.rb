class UpdateUpload < ActiveRecord::Migration
  def up
    remove_column :uploads, :content
  end

  def down
    add_column :uploads, :content
  end
end
