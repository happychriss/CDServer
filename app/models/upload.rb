class Upload < ActiveRecord::Base
  attr_accessible :folder_id, :upload_file, :source
  attr_accessor :upload_file
  belongs_to :folder

  def after_initialize
    self.upload_file ||= [] # just in case the :attachments were passed to .new
  end


  def file_name(type)
    new_file_base_name=self.original_filename.chomp(File.extname(self.original_filename))

    file_name=new_file_base_name + case type
                                     when :pdf
                                       '.pdf'
                                     when :jpg
                                       '.jpg'
                                     when :m_jpg
                                       '_m.jpg'
                                     when :s_jpg
                                       '_s.jpg'
                                     when :txt
                                       '.txt'
                                   end
  end

  def short_path(type)
    File.join('','docstore',self.file_name(type))
  end

  def path(type)
    File.join(Rails.public_path,'docstore',self.file_name(type))
  end


end