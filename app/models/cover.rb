class Cover < ActiveRecord::Base

  attr_accessible :folder_id
  has_many :pages
  belongs_to :folder

  def self.build_pdf(cover)
    tmp_file=File.join(Dir.tmpdir,"#{cover.id}.pdf")
    my_pdf=Prawn::Document.generate(tmp_file,:page_size => 'A4',:page_layout => :landscape) do |pdf|
      pdf.text("Hello Prawn!")
    end
    return tmp_file
  end



end
