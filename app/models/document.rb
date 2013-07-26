class Document < ActiveRecord::Base

  require 'tempfile'

  attr_accessible :comment, :status, :keywords, :keyword_list, :page_count,:pages_attributes, :delete_at, :no_delete
  has_many :pages, :order => :position, :dependent => :destroy
  belongs_to :folder
  accepts_nested_attributes_for :pages, :allow_destroy => true
  acts_as_taggable_on :keywords

  ### Thinking Sphinx
  after_commit :set_delta_flag

  before_update :update_status_new_document
  before_save :update_expiration_date
  before_destroy :check_no_delete

  #### Status
  DOCUMENT=0 ##document was created based on an uploaded document
  DOCUMENT_FROM_PAGE_REMOVED = 1 ##document was created, as a page was removed from an existing doc

  def pdf_file
    docs='';self.pages.each  {|p| docs+=' '+p.path(:pdf)}
    pdf=Tempfile.new(["cd_#{self.id}",".pdf"])
    java_merge_pdf="java -classpath './java_itext/.:./java_itext/itext-5.3.5/*' MergePDF"
    res=%x[#{java_merge_pdf} #{docs} #{pdf.path}]
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

  ### update all pages with the same folder
  def update_folder(folder_id)
    self.pages.update_all :folder_id=>folder_id
  end

  def check_no_delete
    if self.no_delete?
      Log.write_error('MAJOR ERROR', "System tried to delete -NO_DELETE- document with id:#{self.id}")
      raise "ERROR: System tried to delete -NO_DELETE- document with id:#{self.id}"
    end
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

  def update_expiration_date
    self.delete_at=nil if self.delete_at==Date.new(3000) #to allow reset the date back to null (newer expire)
  end
### https://github.com/mperham/sidekiq/blob/master/examples/clockwork.rb
end