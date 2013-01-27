class Page < ActiveRecord::Base

  ## adds function short_path and path to page
  require 'FileSystem'
  include FileSystem

  #### Document Status flow
  UPLOADED = 0 # page just uploaded
  UPLOADED_PROCESSED = 1 # pages is processed by worker
  ASSIGNED_TO_DOCUMENT =2

  attr_accessible :content, :document_id, :original_filename, :position, :source, :folder_id, :upload_file
  attr_accessor :upload_file

  belongs_to :document
  belongs_to :folder

  ########################################################################################################
  ### Sphinx
  define_index do

    indexes content, :as => :content
    indexes document.comment, :as => :document_comment

    has status
    has position, :as => :position, :sortable => true
    has  id, :as => :page_id, :sortable => true

    has document.taggings.tag_id, :as => :tags
    has document.status, :as => :document_status
    has document.created_at, :as => :document_created_at,:sortable => true
    has document.page_count
    has document_id, :as => :group_document

    set_property :delta => true
    set_property :min_prefix_len => 4 ##http://sphinxsearch.com/docs/1.10/conf-min-prefix-len.html
    set_property :field_weights => {:document_comment => 2, :content => 1}
  end

########################################################################################################

  def self.get_search_config(page_no, sort_mode)
    search_config = {:match_mode => :extended,
                     :group_by => 'group_document', #shows only one page, if  more than one pages per document
                     :group_function => :attr,
                     :page => page_no,
                     :per_page => 30,
                     :star => true,
                     :include => {:document => :pages},
                     :order => "position ASC", #order in the group
                     :without => {:status => [UPLOADED, UPLOADED_PROCESSED]} #pages not yet sorted and ready will be ignored
    }

    # http://rdoc.info/github/freelancing-god/thinking-sphinx/ThinkingSphinx/SearchMethods/ClassMethods
    (search_config.merge!({ :group_clause => "document_created_at DESC, page_id DESC"})) if sort_mode==:time

    return search_config
  end

  ########################################################################################################

  def self.search_index(search_string, keywords, page_no, pages_ignore,sort_mode)
  ###https://groups.google.com/forum/?fromgroups=#!msg/thinking-sphinx/WvOTN6NABN0/vzKnhx5CIvAJ

    search_config = Page.get_search_config(page_no,sort_mode)

    if search_string.nil? or keywords.empty? then
      pages=Page.search(search_string, search_config)

    else
      search_config.merge!({:with => {:tags => keywords}})
      pages=Page.search(search_string, search_config)
    end


    puts "***************************************************"
    puts "SearchConfig: #{search_config}"
    pages.each_with_weighting { |p, weight| puts "#{p.id} -P#{p.position} W#{weight} - doc: #{p.document.id} - created: #{p.created_at}" }
    puts "***************************************************"

    ## Pages ignore, are pages that are listed in top of the search results, in order to avoid listing them twice
    pages.delete_if { |p| pages_ignore.index { |pi| pi.id==p.id } }

    return pages

  end

  ########################################################################################################
  ### this page is displayed first in search results with all pages that have been removed from document
  def self.new_document_pages
    pages=Page.search("", Page.get_search_config(1,:relevance).merge!({:with => {:document_status => Document::DOCUMENT_FROM_PAGE_REMOVED}}))
  end

  ########################################################################################################

  def has_document?
    not self.document.nil?
  end


  def document_pages
    return 0 unless self.has_document?
    self.document.page_count
  end

  def self.uploaded_pages
    self.where("document_id is null")
  end

  def destroy_with_file

    position=self.position
    last_page=(self.document_pages==1)

    Dir.glob(self.path(:all)) do |filename|
      File.delete(filename)
    end

    #### page just uploaded
    if self.document.nil?
      self.destroy
      return last_page
    end

    Document.transaction do

      ## if only one page is left and this is destroyed, destroy document
      if self.document_pages==1 then
        self.document.destroy
      else

        document=self.document
        self.destroy

        ### Clean up the document and the remaining pages
        CleanPositionsOnRemove(document.id, position) ## update position of remaining pages
        document.decrement_page_count

      end
    end

    return last_page
    ## return true if this is the last page

  end

  ## remove from document and create a new document
  def move_to_new_document

    ## save all values
    position=self.position
    old_document=self.document

    Page.transaction do
      doc=Document.new(:status => Document::DOCUMENT_FROM_PAGE_REMOVED, :folder_id => self.document.folder_id, :page_count => 1)
      doc.save!
      self.document_id=doc.id
      self.position=0
      self.save!
      CleanPositionsOnRemove(old_document.id, position)
      old_document.decrement_page_count

    end

  end

  ## add new page to a document
  def add_to_document(document, position=document.page_count)

    self.transaction do

      old_document_id=self.document_id

      self.document_id=document.id
      self.position=position
      self.status=ASSIGNED_TO_DOCUMENT
      self.save!

      self.document.increment_page_count

      Document.find(old_document_id).destroy unless old_document_id.nil?

    end

  end

  ## called by the worker to add new content
  def add_content(text_data)
    self.content=text_data
    self.status=UPLOADED_PROCESSED
    self.save!
  end

  private

  def CleanPositionsOnRemove(document_id, position)
    Page.update_all("position = position -1", "document_id = #{document_id} and position > #{position}")
  end

end

