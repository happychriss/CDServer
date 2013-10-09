require 'singleton'
require 'drb'
require 'drb_connector'

class DRBConverter < DRBConnector

  include Singleton

end
