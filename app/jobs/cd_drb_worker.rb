## this is running as a separate ruby daemon on the performand server, to reduce workload from qnap
require 'drb'
require 'drb/acl'
require 'tempfile'
require 'daemons'

class Processor

  def me_alive?
    return true
  end

  def convert(data, source)
    puts "!!!!! Start operation for source:#{source}"
    f = Tempfile.new("cd2_remote")
    f.write(data)
    puts "Tempfile: #{f.path}"

    puts "!!!!! Start sjpg"
    res=%x[convert '#{f.path}' -resize 220x310\! jpg:'#{f.path+'.conv'}']
    result_sjpg=File.read(f.path+'.conv')

    puts "!!!!! Start jpg"
    res=%x[convert '#{f.path}' -resize x770 jpg:'#{f.path+'.conv'}']
    result_jpg=File.read(f.path+'.conv')


    if source==1 then
      puts "!!!!! Start pdf from jpg"
      res = %x[abbyyocr -rl German GermanNewSpelling  -if '#{f.path}'  -f PDF -pem ImageOnText -pfpr original -of '#{f.path}.conv']
      result_pdf=File.read(f.path+'.conv')
      puts "!!!!! Start pdftotxt"
      ## Extract text data and store in database
      res=%x[pdftotext -layout '#{f.path+'.conv'}' #{f.path+'.conv.txt'}]
    else
      ### already a pdf, no need to generate PDF
      puts "!!!!! Start pdftext from jpg"
      res=%x[pdftotext -layout '#{f.path}' #{f.path+'.conv.txt'}]
      result_pdf=data
    end

    result_txt=''
    File.open(f.path+'.conv.txt', 'r') { |f| result_txt=f.read }
    puts "!!!! Completed operation"

#    File.delete(f.path)
#    puts "!!!! Return, file deleted"
    return result_jpg, result_sjpg, result_pdf, result_txt

  end

end

Daemons.run_proc('cd_drb_worker') do

  puts "!!!! Daemon started"

  $SAFE = 1 # disable eval() and friends

  acl = ACL.new(%w{deny all
                  allow localhost
                  allow 192.168.1.*})

  DRb.start_service('druby://0.0.0.0:8999', Processor.new) # replace localhost with 0.0.0.0 to allow conns from outside

  begin
    DRb.thread.join
  rescue Interrupt
  ensure
    DRb.stop_service
  end
end