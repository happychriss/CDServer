class Cover < ActiveRecord::Base

  attr_accessible :folder_id
  has_many :pages
  belongs_to :folder

  after_validation :set_counter

  PAGE_WITH=130
  PAGE_HEIGHT=200

  def self.build_pdf(cover)



    tmp_file=File.join(Dir.tmpdir, "#{cover.id}.pdf")
    x=0
    pages=cover.pages.order('id asc')

    x_max=Prawn::Document::PageGeometry::SIZES["A4"][0]
    y_max=Prawn::Document::PageGeometry::SIZES["A4"][1]
    y_max_pics=y_max-100


    my_pdf=Prawn::Document.generate(tmp_file, :page_size => 'A4') do |pdf|

      pdf.text("Folder: #{cover.folder.name}  --- Count: #{cover.counter} --- IDs #{pages.first.id.to_s} to #{pages.last.id.to_s}")
      pdf.text("Date from #{pages.first.created_at.strftime('%d.%m.%y')} to #{pages.last.created_at.strftime('%d.%m.%y')}")
      pdf.stroke_horizontal_rule
      x=0
      y=pdf.cursor-20

      pdf.font_size=8

      pages.each do |page|
        pdf.image page.path(:s_jpg), :width => PAGE_WITH, :at => [x, y]
        pdf.draw_text "#{page.id}", :at => [x, y]
        x=x+PAGE_WITH+10
        if x>x_max then
          y=y-PAGE_HEIGHT
          x=0
          if y<0 then
            pdf.start_new_page
            y=pdf.cursor
          end

        end
      end


    end

    return tmp_file
  end

  def self.new_with_pages_from_folder(folder_id)

    cover=nil

    pages_no_cover=Page.pages_no_cover(folder_id)

    if pages_no_cover.count>0
      Cover.transaction do
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

end
