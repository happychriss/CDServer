class CoversController < ApplicationController
  # GET /covers
  # GET /covers.json
  def index
    @covers = Cover.order('id desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @covers }
    end
  end

  # GET /covers/1
  # GET /covers/1.json
  # Called by CDClient to read the PDF
  def show
    @cover = Cover.find(params[:id])

    respond_to do |format|
      format.html {send_file(@cover.build_pdf, :type => 'application/pdf', :page => '1')}

      ### returns pdf for the client
      format.json { send_file(@cover.build_pdf, :type => 'application/pdf', :page => '1')}
    end
  end

  # GET /covers/new
  # GET /covers/new.json
  def new

    @cover = Cover.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cover }
    end
  end


  # POST /covers
  # POST /covers.json
  # callled by CDclient to create a new cover

  def create

    folder_id=params[:cover][:folder_id]

    @cover=Cover.new_with_pages_from_folder(folder_id)

    respond_to do |format|
      if @cover.nil? then
        @cover=Cover.new
        format.html { redirect_to @cover, notice: 'No pages found for cover' }
        format.json { render json: @cover, status: :created, location: @cover }
      elsif @cover.save
        format.html {send_file(@cover.build_pdf, :type => 'application/pdf', :page => '1') }
        format.json { render json: @cover, status: :created, location: @cover }
      else
        format.html { render action: "new" }
        format.json { render json: @cover.errors, status: :unprocessable_entity }
      end
    end

  end

  # PUT /covers/1
  # PUT /covers/1.json
  def update
    @cover = Cover.find(params[:id])

    respond_to do |format|
      if @cover.update_attributes(params[:cover])
        format.html { redirect_to @cover, notice: 'Cover was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @cover.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /covers/1
  # DELETE /covers/1.json
  def destroy
    @cover = Cover.find(params[:id])
    @cover.destroy

    respond_to do |format|
      format.html { redirect_to covers_url }
      format.json { head :no_content }
    end
  end

  ############# non standard action

  def show_cover_pages
    @folder=Folder.find(params[:id])
    @page_count=Page.pages_no_cover(@folder.id).count
    @pages=Page.pages_no_cover(@folder.id).limit(20)
  end

end
