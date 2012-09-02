class UploadsController < ApplicationController
  # GET /uploads
  # GET /uploads.json
  def index
    @uploads =Document.AllFirstPages(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @uploads }
    end
  end

  def group
    @drop_doc=Upload.find(params[:drop_id])
    @drag_doc=Upload.find(params[:drag_id])
    Document.AddPage(@drop_doc,@drag_doc)
  end

  # GET /uploads/1
  # GET /uploads/1.json
  def show
    @upload = Upload.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @upload }
    end
  end

  # GET /uploads/new
  # GET /uploads/new.json
  def new
    @upload = Upload.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @upload }
    end
  end

  # GET /uploads/1/edit
  def edit
    @upload = Upload.find(params[:id])
  end

  # POST /uploads
  # POST /uploads.json
  def create
    @upload = Upload.new(params[:upload])
    @upload.original_filename=@upload.upload_file.original_filename

    if @upload.save

      ## Copy to docstore and update DB
      tmp = params[:upload][:upload_file].tempfile

      FileUtils.cp tmp.path, @upload.path(:pdf)

      ## Background: create smaller images and pdf text
      UploadsWorker.perform_async(@upload.id)

      respond_to do |format|
        format.html { redirect_to @upload, notice: 'Upload was successfully created.' }
        format.json { render json: @upload, status: :created, location: @upload }
      end
    else
      format.html { render action: "new" }
      format.json { render json: @upload.errors, status: :unprocessable_entity }
    end
  end


  # PUT /uploads/1
  # PUT /uploads/1.json
  def update
    @upload = Upload.find(params[:id])

    respond_to do |format|
      if @upload.update_attributes(params[:upload])
        format.html { redirect_to @upload, notice: 'Upload was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @upload.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uploads/1
  # DELETE /uploads/1.json
  def destroy
    @upload = Upload.find(params[:id])
    @upload.destroy

    respond_to do |format|
      format.html { redirect_to uploads_url }
      format.json { head :no_content }
      format.js
    end
  end
end


