class UploadSortingController < ApplicationController

  def new

    @document=Document.new

    respond_to do |format|
      format.html { @pages=Page.uploaded_pages } # new.html.erb
      format.js { @pages=nil } #new from ajax
    end
  end


  ###################### Create a new document with pages
  def create

    Document.transaction do
      begin

        @document = Document.new(params[:document])
        @document.save!

        params[:page].each_with_index do |page_id, position|
          p=Page.find(page_id)
          p.add_to_document(@document, position)
        end


        folder_id=params[:folder_id].to_i
        @document.update_folder(folder_id)unless folder_id==0



        Log.write_status('ServerCreateDoc', "Created document with #{@document.reload.page_count} pages!")
      rescue
        Log.write_error('ServerCreateDoc', "ERROR creating document: #{@document.errors.full_messages }!")
        raise
      end

    end

    ## backup new document to Amazon
    BackupWorker.perform_async(@document.id,DRBConnector.instance.processor)
    render action: "new"

  end

  ##### NON HABTM Action


  #### Action triggered by CDClient UPload program


  def destroy_page
    @page = Page.find(params[:id])
    @page.destroy_with_file
  end


end
