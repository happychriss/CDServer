class CoversController < ApplicationController
  # GET /covers
  # GET /covers.json
  def index
    @covers = Cover.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @covers }
    end
  end

  # GET /covers/1
  # GET /covers/1.json
  def show
    @cover = Cover.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @cover }
    end
  end

  # GET /covers/new
  # GET /covers/new.json
  def new

    cover=Cover.find(32)
    pdf_cover_file=Cover.build_pdf(cover)

    send_file(pdf_cover_file, :type => 'application/pdf', :page => '1')
    return

    @cover = Cover.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cover }
    end
  end

  # GET /covers/1/edit
  def edit
    @cover = Cover.find(params[:id])
  end

  # POST /covers
  # POST /covers.json
  def create ##excpects json as //get_folder/id <- folder-id

    Cover.new_with_pages_from_folder(5)
    pdf_cover_file=Cover.build_pdf(@cover)
    send_file(pdf_cover_file, :type => 'application/pdf', :page => '1')

    return

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
    @page_count=Page.no_cover(@folder.id).count
    @pages=Page.no_cover(@folder.id).limit(20)
  end

end
