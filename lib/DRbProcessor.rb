module DRbProcessor
## called by convert_worker
## this is running as a separate ruby daemon on a more performant server, to reduce workload from qnap nas
## at the end of the file the command is executed.


  require 'tempfile'


  class Processor

    def self.command_exits?(command)
      puts "Check command #{command} with result: #{%x[which '#{command}']}"
      %x[which '#{command}']!=''
    end

    def check_program(program)
      raise "Processor-Client *#{program}* command missing" unless Processor.command_exits?(program)
    end


    def me_alive?
      return true
    end


    ### this part is running on the remove server (desktop) not on the qnas, should have convert and pdftotext installed
    def convert(data, mime_type)

      begin

      puts "!!!!! Start operation for mime_type: #{mime_type.to_s}"

      f = Tempfile.new("cd2_remote")
      f.write(data)
      puts "Tempfile: #{f.path}"

      # abbyyocr ###############################################

      if [:PDF, :JPG, :JPG_SCANNED].include?(mime_type) then

        check_program('convert');check_program('pdftotext');check_program('abbyyocr')

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
        return result_jpg, result_sjpg, result_pdf, result_txt,'OK'
      end

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

      if [:MS_EXCEL,:MS_WORD,:ODF_CALC,:ODF_WRITER].include?(mime_type) then

        check_program('convert');check_program('html2ps');

        tinka_path=File.join('/home/development/bin','tika-app-1.4.jar')
#        tinka_path=File.join(File.dirname(__FILE__),'tika-app-1.4.jar')

        puts "Tika java path: #{tinka_path}"


        puts "!!!!! Start Tinka Conversion"
        command="java -jar #{tinka_path} -h '#{f.path}' >> #{f.path+'.conv.html'}"
        puts command

        res=%x[#{command}]
#        res=%x[java -version]
#        res=%x[java -jar #{tinka_path} -h '#{f.path}' >> #{f.path+'.conv.html'}]
#        res=%x[java -jar #{tinka_path} -V]
#        res=%x[java -jar /home/development/Projects/CD2/CDServer/lib/tika-app-1.4.jar -V]
        puts "Result: #{res}"

        puts "!!!!! Start sjpg"
        res=%x[convert '#{f.path+'.conv.html'}'[0] -resize 350x490\! jpg:'#{f.path+'.conv'}'] #convert only first page if more exists
        result_sjpg=File.read(f.path+'.conv')

        puts "!!!!! Start jpg"
        res=%x[convert '#{f.path+'.conv.html'}'[0] -resize x770 jpg:'#{f.path+'.conv'}'] #convert only first page if more exists
        result_jpg=File.read(f.path+'.conv')

        File.delete(f.path+'.conv.html')

        res=%x[java -jar #{tinka_path} -t '#{f.path}' >> #{f.path+'.conv.txt'}]

        result_txt=''
        File.open(f.path+'.conv.txt', 'r') { |f| result_txt=f.read }
        puts "!!!! Completed operation"

        File.delete(f.path)
        puts "!!!! Return, file deleted"

        return result_jpg, result_sjpg, result_pdf, result_txt,'OK'
      end

      rescue Exception => e
        puts "Error:"+ e.message
        return nil, nil, nil, nil,"Error:"+ e.message
      end
    end

  end
end


