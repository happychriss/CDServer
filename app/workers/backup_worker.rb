class BackupWorker
  require 'tmpdir'
  include Sidekiq::Worker
  sidekiq_options :retry => true

  def perform(document_id)

    # create a connection
    gpg_email=Array.new(1, AWS_S3::GPG_EMAIL_ADDRESS)
    connection= AWS::S3::Base.establish_connection!(:access_key_id => AWS_S3::AWS_S3_ACCESS_KEY, :secret_access_key => AWS_S3::AWS_S3_SECRET_KEY)

    doc=Document.find(document_id)
    logger.info "### LOAD DAEMON:---Start Uploading for document #{doc.id} with #{doc.page_count} pages ------------"

    doc.pages.each do |page|

      if page.backup==false then

        source_name=page.path(:pdf)
        pgp_name=File.join(Dir.tmpdir, page.file_name(:gpg))

        ####### Debugging
        info_text=" page_id: #{page.id} doc_id: #{doc.id} pgp_name: #{pgp_name} AmazonBucket: #{AWS_S3::AWS_S3_BUCKET}"
        backup_count=$redis.incr('backup_count'); $redis.set("backup_status", "working")
        logger.info "### LOAD DAEMON:---START Upload --- RedisCount: #{backup_count}"+info_text

        #### Encrypt file
        command = "gpg -q --no-verbose --yes -a -o #{pgp_name} -r " + AWS_S3::GPG_EMAIL_ADDRESS + " -e #{source_name}"
        system(command)

        begin
          result=AWS::S3::S3Object.store(File.basename(pgp_name), open(pgp_name), AWS_S3::AWS_S3_BUCKET)
          File.delete(pgp_name);
          page.update_attribute('backup', true)

          backup_count=$redis.decr('backup_count'); $redis.set("backup_status", "ok")
          Log.write('Backup',"Backup completed for page_id #{page.id} doc_id #{doc.id} to Amazon #{AWS_S3::AWS_S3_BUCKET} with #{pgp_name}")
          logger.info "### LOAD DAEMON:---COMPLETE Upload --- RedisCount: #{backup_count}"+info_text
        rescue
          errormsg="### LOAD DAEMON:--- ERROR !!!!!!!!!! Upload error for #{info_text} - check logfile"
          $redis.set("backup_status",errormsg );logger.info errormsg
          Log.write('Backup',"ERROR !!!!!!1 Backup for "+info_text)
          raise
        end

      end

    end
  end

end

