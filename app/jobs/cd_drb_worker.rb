## this is running as a separate ruby daemon on the performand server, to reduce workload from qnap
require 'drb'
require 'tempfile'

class Processor

  def convert(data)
    puts "!!!!! Start operation3"
    f = Tempfile.new("cd2_remote")
    f.write(data)

    puts "!!!!! Start sjpg"
    res=%x[convert '#{f.path}' -resize 220x230\! '#{f.path+'.conv'}']
    result_sjpg=File.read(f.path+'.conv')

    puts "!!!!! Start jpg"
    res=%x[convert '#{f.path}' -resize x770 '#{f.path+'.conv'}']
    result_jpg=File.read(f.path+'.conv')

    puts "!!!!! Start pdf"
    res = %x[abbyyocr -rl German GermanNewSpelling  -if '#{f.path}'  -f PDF -pem ImageOnText -pfpr original -of '#{f.path}.conv']
    result_pdf=File.read(f.path+'.conv')

    puts "!!!!! Start pdftotxt"
    ## Extract text data and store in database
    res=%x[pdftotext -layout '#{f.path+'.conv'}']
    result_txt=''
    File.open(f.path+'.conv.txt', 'r') { |f| result_txt=f.read }
    puts "!!!! Completed operation"
    return result_jpg, result_sjpg, result_pdf, result_txt

  end

end

DRb.start_service('druby://localhost:9000', Processor.new) # replace localhost with 0.0.0.0 to allow conns from outside
DRb.thread.join