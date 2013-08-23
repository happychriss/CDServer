class UploadsController < ApplicationController
  require 'fileutils'

  def new

  end

  #### Upload file directly from CDServer via Upload Dialogue, PDF currently
  def create

    if params[:file_upload].nil? or params[:file_upload][:my_file].nil?
      flash[:error] = "No filename entered."
      render :action => 'new'
      return
    end

    upload_file= params[:file_upload][:my_file]

    unless Page::PAGE_MIME_TYPES.has_key?(upload_file.content_type)
      flash[:error] = "File format not supported, detected type: #{upload_file.content_type} - supportet tpyes: #{Page::PAGE_MIME_TYPES.to_s}."
      render :action => 'new'
      return
    end

    page=Page.new(
        :original_filename => upload_file.original_filename,
        :source => Page::PAGE_SOURCE_UPLOADED,
        :folder_id => params[:file_upload][:folder_id],
        :mime_type => Page::PAGE_MIME_TYPES[upload_file.content_type])

    page.save!
    page.reload

    FileUtils.cp upload_file.tempfile.path, page.path(:orginal)
    FileUtils.chmod "go=rr", page.path(:orginal)

    # Background: create smaller images and pdf text
    if RemoteConvertWorker.connected? then
      rm=RemoteConvertWorker.new
      rm.perform([page.id])
#      RemoteConvertWorker.perform([page.id])
    else
      LocalConvertWorker.perform_async(page.id)
    end

    redirect_to new_upload_path, notice: 'Upload was successfully created.'

  end

  ### Upload from CDClient (Scanner) - file uploaded as JPG - single pages as jpg
  def create_from_client_jpg

    @page = Page.new(params[:page])
    @page.original_filename=@page.upload_file.original_filename
    @page.position=0
    @page.source=Page::PAGE_SOURCE_SCANNED

    if @page.save

      ## Copy to docstore and update DB -- will be .scanned.jpg
      tmp = params[:page][:upload_file].tempfile
      FileUtils.cp tmp.path, @page.path(:orginal)
      FileUtils.chmod "go=rr", @page.path(:orginal) #happens only on qnas, set group and others to read, otherwise nginx fails

      ## just if provided in addition, we are happy, will be _s.jpg
      if  not params[:small_upload_file].nil? then
        tmp_small = params[:small_upload_file].tempfile
        FileUtils.cp tmp_small.path, @page.path(:s_jpg)
        FileUtils.chmod "go=rr", @page.path(:s_jpg)
      end

      ## Background: create smaller images and pdf text

      if RemoteConvertWorker.connected? then
        RemoteConvertWorker.perform_async([@page.id])
      else
        @page.update_status_preview(Page::UPLOADED_NOT_PROCESSED)
      end

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
