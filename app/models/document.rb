class Document < ActiveRecord::Base

  require 'tempfile'
  require 'rjb'

  attr_accessible :comment, :folder_id, :status, :keywords, :keyword_list, :page_count,:pages_attributes
  has_many :pages, :order => :position, :dependent => :destroy
  accepts_nested_attributes_for :pages, :allow_destroy => true
  acts_as_taggable_on :keywords


  ### Thinking Sphinx
  after_commit :set_delta_flag

  before_update :update_status_new_document

  #### Status
  DOCUMENT=0 ##document was created based on an uploaded document
  DOCUMENT_FROM_PAGE_REMOVED = 1 ##document was created, as a page was removed from an existing doc

  def pdf_file

    pdf=Tempfile.new(["cd_#{self.id}",".pdf"])
    filestream = $filestream.new(pdf.path)
    copy = $pdfcopyfields.new(filestream)

    self.pages.each do |p|
      new_doc=$pdfreader.new(p.path(:pdf))
      copy.addDocument(new_doc)
    end
    copy.close()
    return pdf
  end

  def backup?
    self.pages.where("backup = 0").count==0
  end

  def increment_page_count
    self.update_attribute('page_count',self.page_count+1)
  end

  def decrement_page_count
    self.update_attribute('page_count',self.page_count-1)
  end


  private

##http://stackoverflow.com/questions/4902804/using-delta-indexes-for-associations-in-thinking-sphinx
  def set_delta_flag
    self.pages.update_all("delta=1")
    Page.define_indexes
    Page.index_delta
  end

  def update_status_new_document
    self.status=DOCUMENT if self.status_was==DOCUMENT_FROM_PAGE_REMOVED
  end

### https://github.com/mperham/sidekiq/blob/master/examples/clockwork.rb
end