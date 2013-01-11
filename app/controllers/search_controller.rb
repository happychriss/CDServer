
class SearchController < ApplicationController

  def search
    @current_keywords||= []
  end

  def found

    session[:search_results] = request.url

    @current_keywords=params[:document].nil? ? []:params[:document][:keyword_list]

    @pages_new_document=Page.new_document_pages ##pages that have been assigned a new document (remove action in document.edit)
    @pages=Page.search_index(params[:q],@current_keywords, params[:page],@pages_new_document)

    @q=params[:q]

    render :action => 'search'

end

  ## add a page to the document via drag and drop (from search screen)
  def add_page
    drag_id=params[:drag_id][/\d+/].to_i
    drop_id=params[:drop_id][/\d+/].to_i #I get the new page

    @drag_page=Page.find(drag_id)
    @drop_page=Page.find(drop_id)

    @drag_page.add_to_document(@drop_page.document)
  end

  ### Show document PDF and RTF

  def show_rtf
    @page=Page.find(params[:id])
  end

  def show_pdf
    @page=Page.find(params[:id])
    pdf=@page.document.pdf_file
    send_file(pdf.path, :type => 'application/pdf', :page => '1')
    pdf.close
    return
  end

end



