require 'singleton'
require 'drb'


class DaemonConverter < DaemonConnector

  include Singleton

  def initialize
    super
    @uri="druby://#{DRB_WORKER['remote_host']}:#{DRB_WORKER['remote_port_converter']}"
  end

end
