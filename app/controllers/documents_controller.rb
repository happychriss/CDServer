class DocumentsController < ApplicationController

  # GET /documents/1/edit
  def edit
    @document = Document.find(params[:id], :include => :pages)
  end

  def update
    @document = Document.find(params[:id])

    begin
      Document.transaction do
        @document.update_attributes(params[:document])

        folder_id=params[:folder_id].to_i
        @document.update_folder(folder_id) unless folder_id==0

      end
      redirect_to session[:search_results]+"#page_#{@document.pages.first.id}", :notice => "Successfully updated doc."
    rescue
      raise "ERROR"
    end

  end


  def destroy_page
    @page = Page.find(params[:id])
    @page.destroy_with_file


    respond_to do |format|
      format.html { redirect_to search_url }
      format.js {}
    end

  end

  ################################### non HABTM ################################################


  ### UPDATE Document

  ## remove a page from the document via the edit action
  def remove_page

    @page = Page.find(params[:id])
    @document=@page.document

    @page.move_to_new_document

  end

  ### called in update document when the document is re-ordered
  def sort_pages
    params[:page].each_with_index do |page_id, position|
      page=Page.find(page_id)
      page.position=position
      page.save!
    end

    render :nothing => true
  end


end
