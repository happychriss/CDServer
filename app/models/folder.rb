class Folder < ActiveRecord::Base
  attr_accessible :name
  has_many :uploads
  default_scope :order => 'name'
end
