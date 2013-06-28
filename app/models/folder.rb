class Folder < ActiveRecord::Base

  MIGRATION_FOLDER = 9999

  attr_accessible :name, :short_name , :cover_ind
  has_many :pages
  has_many :covers
  default_scope :order => 'name'
  default_scope where ("id < #{Folder::MIGRATION_FOLDER}")

  ### used to print cover pages

  def get_pages_no_cover
    Folder.Documents.where()
    Do
    self.where('cover_id is null and ')
  end


end
