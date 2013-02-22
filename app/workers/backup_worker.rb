## this does overwrite gpgr.rb - command for gpg path, as it assumes it in '/usr/bin/env gpg'
module Gpgr

  def self.command
    'gpg'
  end
end

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

        backup_count=$redis.incr('backup_count');  logger.info "### LOAD DAEMON:---START Redis Initial BackupCount #{backup_count}"

        source_name=page.path(:pdf)
        pgp_name=File.join(Dir.tmpdir, page.file_name(:gpg))

        Gpgr::Encrypt.file(source_name, :to => pgp_name).encrypt_using(gpg_email)
        logger.info "### LOAD DAEMON:Start uploading for page #{page.id} of #{doc.id}"

        AWS::S3::S3Object.store(File.basename(pgp_name), open(pgp_name), AWS_S3::AWS_S3_BUCKET)

        File.delete(pgp_name); logger.info "### LOAD DAEMON:Uploading Page Completed"

        page.update_attribute('backup', true)

        backup_count=$redis.decr('backup_count');    logger.info "STOP Redis Initial Upload Count #{backup_count}"

      end

    end

    Log.write("Backup", "Completed backup for document #{doc.id} to #{AWS_S3::AWS_S3_BUCKET}")

  end

end
