module FileSystem
  def file_name(type)
    #new_file_base_name=self.id.to_s + '_' + self.original_filename.chomp(File.extname(self.original_filename))

    new_file_base_name=self.id.to_s

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
                                     when :all
                                      '*.*'
                                   end
  end

  def short_path(type)
    File.join('','docstore',self.file_name(type))
  end

  def path(type)
    File.join(Rails.public_path,'docstore',self.file_name(type))
  end
end