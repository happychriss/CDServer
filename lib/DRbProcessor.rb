module DRbProcessor
## this is running as a separate ruby daemon on the performand server, to reduce workload from qnap
## at the end of the file the command is executed.

  require 'tempfile'


  class Processor

    def self.command_exits?(command)
      puts "Check command #{command} with result: #{%x[which '#{command}']}"
      %x[which '#{command}']!=''
    end

    def me_alive?
      return true
    end

    def convert(data, source)

      raise 'Processor-Client *CONVERT* command missing' unless Processor.command_exits?('convert')
      raise 'Processor-Client *pdftotext* command missing' unless Processor.command_exits?('pdftotext')

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

      if source==1 then ### means this is uploaded via Client, we need to do OCR and to have abby installed

        raise 'Processor-Client *abbyyocr* command missing' unless Processor.command_exits?('abbyyocr')

        puts "!!!!! Start pdf from jpg"
#        res = %x[abbyyocr -rl German GermanNewSpelling  -if '#{f.path}'  -f PDF -pem ImageOnText -pfpr original -of '#{f.path}.conv']
        puts "!!!!!!!!!!!DUMMY!!!!!!!!!!!! dont forget to replace ;"
        sleep(2)
        res= %x[convert '#{f.path}' pdf:'#{f.path+'.conv'}']
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
end

