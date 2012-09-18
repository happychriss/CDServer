class UploadDocId < ActiveRecord::Base

  def self.AllFirstUploadPages(paginate_page)

    ## returns only the first pages
    #    return Upload.select("*,min(position)").group("document_id").having("position=min(position)").order('id asc')

    sql="(
      SELECT *
        FROM `uploads`
        GROUP BY document_id
        HAVING position = min( position )
      )
      UNION (
        SELECT *
        FROM `uploads`
        WHERE document_id =0
      )
      ORDER BY id"

    return Upload.paginate_by_sql(sql,:page => paginate_page,  :per_page => 100)

  end

  def self.PageCount(page)
    return 1 if  page.document_id==0
    page.class.where(:document_id => page.document_id).count
  end

  def self.AddPage(page_parent, page_new)

    new_document_id=0

    ### scenario 1: 1 new_page (document_id=0) add to 1 parent_page (document_id=0)

    if page_new.document_id ==0 and page_parent.document_id==0  then
      doc=self.first!
      doc.with_lock do
        new_document_id=doc.document_id+1
        doc.document_id=new_document_id
        doc.save!
        page_parent.document_id=new_document_id
        page_parent.save!
      end
      new_position=1

      ### scenario 2: 1 new_page (document_id=0) add to 1 parent_page (document_id not empty)

    elsif page_new.document_id==0 and page_parent.document_id!=0  then
      new_document_id=page_parent.document_id
      new_position=page_parent.class.where(:document_id => new_document_id).maximum(:position)+1
    else raise "Drag and Drop Error"
    end

    page_new.document_id=new_document_id
    page_new.position=new_position
    page_new.save!

  end

  def self.GetPages(page)
    page.class.where("(document_id = :document_id and document_id <>0) or id=:page_id", {:document_id => page.document_id, :page_id => page.id}).order(:position)

  end


end