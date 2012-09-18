class Upload < ActiveRecord::Base

  require 'FileSystem'
  include FileSystem

  attr_accessible :folder_id, :upload_file, :source
  attr_accessor :upload_file
  belongs_to :folder

  def after_initialize
    self.upload_file ||= [] # just in case the :attachments were passed to .new
  end

  def document?
    (self.document_id!=0 ? true : false)
  end

end