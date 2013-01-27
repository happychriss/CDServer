class Log < ActiveRecord::Base
  attr_accessible :message, :source

  def self.write(source,message)
    log = Log.new(:source => source, :message => message)
    log.save!
  end


end
