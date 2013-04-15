class Cover < ActiveRecord::Base

  attr_accessible :folder_id
  has_many :pages
  belongs_to :folder

  after_validation :set_counter
 before_destroy :update_pages

  PAGE_WITH=130
  PAGE_HEIGHT=200

  X_MAX = Prawn::Document::PageGeometry::SIZES["A4"][0]
  Y_MAX=Prawn::Document::PageGeometry::SIZES["A4"][1]
  X_MIDDLE=X_MAX/2-30
  Y_MIDDLE=Y_MAX/2-35

  BOTTOM_SPACE=150 #for folder line


  def bottom_page(pdf)
    pdf.move_cursor_to BOTTOM_SPACE
    pdf.stroke_horizontal_rule
    pdf.fill_circle [X_MIDDLE,BOTTOM_SPACE],10
  end


  def build_pdf

    tmp_file=File.join(Dir.tmpdir, "#{self.id}.pdf")

    y_max_pics=BOTTOM_SPACE ##y=0 is bottom of page

    pages=self.pages.order('id asc')

    my_pdf=Prawn::Document.generate(tmp_file, :page_size => 'A4') do |pdf|

      page_no=1

      cover_line= "  * #{self.counter} *    Folder:#{self.folder.short_name}"
      cover_line+="          IDs: #{pages.first.id.to_s} to #{pages.last.id.to_s}"
      cover_line+="          Date: #{self.created_at.strftime('%d.%m.%y')}                Page: #{page_no} (Cover:#{self.id})"
      pdf.text cover_line

      pdf.stroke_horizontal_rule

      x=0
      y=pdf.cursor-20

      pages.each do |page|
        pdf.image page.path(:s_jpg), :width => PAGE_WITH, :at => [x, y]
        pdf.draw_text "#{page.id}", :at => [x, y], :size => 8

        x=x+PAGE_WITH+10
        if x>X_MAX then ## new row
          y=y-PAGE_HEIGHT
          x=0

          if y<y_max_pics then # new page

            bottom_page(pdf) if page_no==1

            page_no=page_no+1

            pdf.start_new_page
            pdf.text "Page: #{page_no}"
            pdf.stroke_horizontal_rule
            pdf.fill_circle [0,Y_MIDDLE],10

            y=pdf.cursor-20
            y_max_pics=5
          end

        end ## end of new roe

        bottom_page(pdf) if page_no==1

      end ## of pages loop

    end

    return tmp_file
  end




  def self.new_with_pages_from_folder(folder_id)

    cover=nil

    pages_no_cover=Page.pages_no_cover(folder_id)

    if pages_no_cover.count>0
      self.transaction do
        cover = Cover.new
        cover.folder_id=folder_id
        cover.save!
        pages_no_cover.update_all(:cover_id => cover.id)
      end
    end
    return cover
  end

  private


### This counts per folder

  def set_counter
    self.counter=(Cover.where(:folder_id => self.folder_id).maximum('counter').to_i)+1
  end


### remove cover from all pages
  def update_pages
    self.pages.clear
  end


end
