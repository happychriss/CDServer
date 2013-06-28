class DropColumnFormatFromPages < ActiveRecord::Migration
  def up
    remove_column :pages, :format
  end

  def down
  end
end
