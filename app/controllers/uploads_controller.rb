require 'fileutils'
require 'Pusher'


class UploadsController < ApplicationController

  include Pusher

  def new

  end

  #### Upload file directly from CDServer via Upload Dialogue
  def create_from_upload

    if params[:file_upload].nil? or params[:file_upload][:my_file].nil?
      flash[:error] = "No filename entered."
      render :action => 'new'
      return
    end

    upload_file= params[:file_upload][:my_file]

    unless Page::PAGE_MIME_TYPES.has_key?(upload_file.content_type)
      flash[:error] = "File format not supported, detected type: ****** #{upload_file.content_type} ******- supportet tpyes: #{Page::PAGE_MIME_TYPES.to_s}."
      render :action => 'new'
      return
    end

    page=Page.new(
        :original_filename => upload_file.original_filename,
        :source => Page::PAGE_SOURCE_UPLOADED,
        :mime_type => upload_file.content_type)

    page.save!
    page.reload

    FileUtils.cp upload_file.tempfile.path, page.path(:org)
    FileUtils.chmod "go=rr", page.path(:org)

    # Background: create smaller images and pdf text
    if DaemonConverter.instance.drb_connected?
      RemoteConvertWorker.my_perform([page.id])
    else
      LocalConvertWorker.perform_async(page.id)
    end

    redirect_to new_upload_path, notice: 'Upload was successfully created.'

  end

  ### Upload from CDClient (Scanner) - file uploaded as JPG - single pages as jpg
  def create_from_scanner_jpg

    @page = Page.new(params[:page])
    @page.original_filename=@page.upload_file.original_filename
    @page.position=0
    @page.source=Page::PAGE_SOURCE_SCANNED
    @page.mime_type='image/jpeg'
    @page.preview=true
    @page.save!

    ## Copy to docstore and update DB -- will be .scanned.jpg
    tmp = params[:page][:upload_file].tempfile
    FileUtils.cp tmp.path, @page.path(:org)
    FileUtils.chmod "go=rr", @page.path(:org) #happens only on qnas, set group and others to read, otherwise nginx fails

    ## just if provided in addition, we are happy, will be _s.jpg
    if  not params[:small_upload_file].nil? then
      tmp_small = params[:small_upload_file].tempfile
      FileUtils.cp tmp_small.path, @page.path(:s_jpg)
      FileUtils.chmod "go=rr", @page.path(:s_jpg)
    end

    ## Background: create smaller images and pdf text

    if DaemonConverter.instance.drb_connected? then
      RemoteConvertWorker.my_perform([@page.id])
    else
      @page.update_status_preview(Page::UPLOADED_NOT_PROCESSED)
    end

    ## this triggers the pusher to update the page with new uploaded data
    render('create_from_scanner_jpg', :handlers => [:erb], :formats => [:js])

  end


  ### called from mobile device to check if cdserver is available
  def cd_server_status_for_mobile
    render :nothing => true
  end


  ## file will be saved as PDF, not JPG
  def create_from_mobile_jpg


    upload_file=params[:upload_file]

    page=Page.new(
        :original_filename => File.basename(upload_file.original_filename)+'.pdf',
        :source => Page::PAGE_SOURCE_MOBILE,
        :mime_type => 'image/jpeg')


    page.save!
    page.reload

    ## Copy to docstore and update DB -- will be .scanned.jpg
    tmp = upload_file.tempfile
    FileUtils.cp tmp.path, page.path(:org)
    FileUtils.chmod "go=rr", page.path(:org) #happens only on qnas, set group and others to read, otherwise nginx fails

    if DaemonConverter.instance.drb_connected?
      RemoteConvertWorker.my_perform([page.id])
    else
      LocalConvertWorker.perform_async(page.id)
    end

    render :nothing => true

  end


end
