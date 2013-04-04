class UploadsController < ApplicationController
  require 'fileutils'

  def new

  end

  #### Upload file directly from CDServer via Upload Dialogue
  def create

    if params[:file_upload].nil? or params[:file_upload][:my_file].nil?
      flash[:error] = "No filename entered."
      render :action => 'new'
      return
    end

    upload_file= params[:file_upload][:my_file]
    if upload_file.content_type != "application/pdf" then
      flash[:error] = "Only PDF Files supported for upload."
      render :action => 'new'
      return
    end

    page=Page.new(
        :original_filename => upload_file.original_filename,
        :source => Page::PAGE_SOURCE_UPLOADED,
        :format => Page::PAGE_FORMAT_PDF,
        :folder_id => params[:file_upload][:folder_id])

    page.save!
    page.reload

    FileUtils.cp upload_file.tempfile.path, page.tmp_docstore_path

    # Background: create smaller images and pdf text
    ConvertWorker.perform_async(page.id)

    redirect_to new_upload_path, notice: 'Upload was successfully created.'

  end

  ### Upload from CDClient (Scanner) - file uploaded as JPG
  def create_from_client_jpg

    @page = Page.new(params[:page])
    @page.original_filename=@page.upload_file.original_filename
    @page.position=0
    @page.format=Page::PAGE_FORMAT_SCANNED_JPG

    if @page.save

      ## Copy to docstore and update DB
      tmp = params[:page][:upload_file].tempfile


      FileUtils.cp tmp.path, @page.tmp_docstore_path

      ## Background: create smaller images and pdf text
      ConvertWorker.perform_async(@page.id)

      respond_to do |format|
        format.html { redirect_to @page, notice: 'Upload was successfully created.' }
        format.json { render :nothing => true }
      end
    else
      format.html { render action: "new" }
      format.json { render json: @page.errors, status: :unprocessable_entity }
    end
  end


end
