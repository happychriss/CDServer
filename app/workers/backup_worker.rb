class BackupWorker
  require 'tmpdir'
  require 'Pusher'
  include Sidekiq::Worker
  include Pusher
  include ActionView::Helpers::UrlHelper

  sidekiq_options :retry => true

  def perform(document_id)

    begin

      info_text=''

      # create a connection
      gpg_email=Array.new(1, AWS_S3['gpg_email_address'])
      connection= AWS::S3::Base.establish_connection!(:access_key_id => AWS_S3['aws_s3_access_key'], :secret_access_key => AWS_S3['aws_s3_secret_key'])

      doc=Document.find(document_id)
      logger.info "### LOAD DAEMON:---Start Uploading for document #{doc.id} with #{doc.page_count} pages ------------"

      doc.pages.each do |page|

        if page.backup==false then

          push_status_update ## send status-update to application main page via private_pub gem, fayes,

          source_name=page.path(:pdf)
          pgp_name=File.join(Dir.tmpdir, page.file_name(:gpg))

          ####### Debugging
          info_text=" page_id: #{page.id} doc_id: #{doc.id} pgp_name: #{pgp_name} AmazonBucket: #{AWS_S3['aws_s3_bucket']}"

          #### Encrypt file
          command = "gpg -q --no-verbose --yes -a -o #{pgp_name} -r " + AWS_S3['gpg_email_address'] + " -e #{source_name}"
          system(command)

          result=AWS::S3::S3Object.store(File.basename(pgp_name), open(pgp_name), AWS_S3['aws_s3_bucket'])
          File.delete(pgp_name);
          page.update_attribute('backup', true)

          push_status_update ## send status-update to application main page via private_pub gem, fayes,

          Log.write_status('backup', "backup completed for page_id #{page.id} doc_id #{doc.id} to Amazon #{AWS_S3['aws_s3_bucket']} with #{pgp_name}")

        end

      end
    end
  rescue Exception => e
    Log.write_error('BackupWorker', info_text + '->' +e.message)
    push_status_update ## send status-update to application main page via private_pub gem, fayes,
    raise
  end


end

