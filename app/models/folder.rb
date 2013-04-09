class Folder < ActiveRecord::Base
  attr_accessible :name, :short_name , :cover_ind
  has_many :pages
  has_many :covers
  default_scope :order => 'name'

  ### used to print cover pages

  def get_pages_no_cover
    Folder.Documents.where()
    Do
    self.where('cover_id is null and ')
  end


end
