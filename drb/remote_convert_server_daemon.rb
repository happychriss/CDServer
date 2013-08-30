###  Server Daemon to convert data on a more performant server - called via distributed ruby DRB
require 'drb'
require 'drb/acl'
require 'daemons'
require 'tempfile'

class Processor


  def me_alive?
    return true
  end


  ### this part is running on the remove server (desktop) not on the qnas, should have convert and pdftotext installed
  def converter(data, mime_type)

    begin

      puts "!!!!! Start operation for mime_type: #{mime_type.to_s}"

      f = Tempfile.new("cd2_remote")
      f.write(data)
      puts "Tempfile: #{f.path}"

      # abbyyocr ###############################################



      if [:PDF, :JPG, :JPG_SCANNED].include?(mime_type) then

        check_program('convert'); check_program('pdftotext'); check_program('abbyyocr')

        puts "!!!!! Start sjpg"
        res=%x[convert '#{f.path}'[0] -resize 350x490\! jpg:'#{f.path+'.conv'}'] #convert only first page if more exists
        result_sjpg=File.read(f.path+'.conv')

        puts "!!!!! Start jpg"
        res=%x[convert '#{f.path}'[0] -resize x770 jpg:'#{f.path+'.conv'}'] #convert only first page if more exists
        result_jpg=File.read(f.path+'.conv')

        puts "!!!!! Start pdf from jpg"
        res = %x[abbyyocr -rl German GermanNewSpelling  -if '#{f.path}'  -f PDF -pem ImageOnText -pfpr original -of '#{f.path}.conv']
        result_pdf=File.read(f.path+'.conv')

        puts "!!!!! Start pdftotxt"
                                                                                 ## Extract text data and store in database
        res=%x[pdftotext -layout '#{f.path+'.conv'}' #{f.path+'.conv.txt'}]
        result_txt=''
        File.open(f.path+'.conv.txt', 'r') { |f| result_txt=f.read }
        puts "!!!! Completed operation"

        File.delete(f.path)
        puts "!!!! Return, file deleted"
        return result_jpg, result_sjpg, result_pdf, result_txt, 'OK'


      # CATDOC ###############################################

=begin
      if mime_type==:MS_WORD then

        raise 'Processor-Client *catdoc* command missing' unless Processor.command_exits?('catdoc')

        puts "!!!!! Start CatDoc"
        ## Extract text data and store in database
        res=%x[catdoc '#{f.path}' >> #{f.path+'.conv.txt'}]
        result_txt=''
        File.open(f.path+'.conv.txt', 'r') { |f| result_txt=f.read }
        puts "!!!! Completed operation"

        File.delete(f.path)
        puts "!!!! Return, file deleted"

        return nil, nil, nil, result_txt,'OK'
      end
=end

      ## Tika ############################### http://tika.apache.org/

      elsif [:MS_EXCEL, :MS_WORD, :ODF_CALC, :ODF_WRITER].include?(mime_type) then

        tika_path='tika-app-1.4.jar'
        check_program('convert'); check_program('html2ps');check_program('tika-app-1.4.jar') ##jar can be called directly

        ############### Create Preview Pictures of uploaded file

        puts "!!!!! Start Tika Conversion"
        command="tika-app-1.4.jar -h '#{f.path}' >> #{f.path+'.conv.html'}"
        puts command

        res=%x[#{command}]
        puts "Result: #{res}"

        puts "!!!!! Start sjpg"
        res=%x[convert '#{f.path+'.conv.html'}'[0] jpg:'#{f.path+'.conv.tmp'}'] #convert only first page if more exists

        res=%x[convert '#{f.path+'.conv.tmp'}' -resize 350x490\! jpg:'#{f.path+'.conv'}'] #convert only first page if more exists
        result_sjpg=File.read(f.path+'.conv')

        puts "!!!!! Start jpg"
        res=%x[convert '#{f.path+'.conv.tmp'}'[0] -resize x770 jpg:'#{f.path+'.conv'}'] #convert only first page if more exists
        result_jpg=File.read(f.path+'.conv')

        File.delete(f.path+'.conv.tmp')
        File.delete(f.path+'.conv.html')

        ################ Extract Test from uploaded file

        res=%x[tika-app-1.4.jar -t '#{f.path}' >> #{f.path+'.conv.txt'}]

        result_txt=''
        File.open(f.path+'.conv.txt', 'r') { |f| result_txt=f.read }
        puts "!!!! Completed operation"

        File.delete(f.path)
        puts "!!!! Return, file deleted"

        result_pdf=nil
        return result_jpg, result_sjpg, result_pdf, result_txt, 'OK'
      else
        raise "Unkonw mime -type  *#{mime_type}*"
        end

    rescue Exception => e
      puts "Error:"+ e.message
      return nil, nil, nil, nil, "Error:"+ e.message
    end
  end

private

  def check_program(command)
    puts "Check command #{command}.."
    if %x[which '#{command}']=='' then
      raise "Processor-Client *#{command}* command missing"
    else
      puts "..OK"
      end

  end

end




# ***************************************************************************************************

Daemons.run_proc("DRbProcessorRemoveServer.rb", options = {:dir_mode => :normal, :ARGV => ARGV, :log_output => true}) do

  $SAFE = 1 # disable eval() and friends

  acl = ACL.new(%w{deny all
                  allow localhost
                  allow 192.168.1.*}) ## from local subnet

  puts "In Daemons run_proc in remote mode on port 8999"
  DRb.start_service("druby://0.0.0.0:8999", Processor.new) # replace localhost with 0.0.0.0 to allow conns from outside

  begin
    DRb.thread.join
  rescue Interrupt
  ensure
    DRb.stop_service
  end
end


# ***************************************************************************************************