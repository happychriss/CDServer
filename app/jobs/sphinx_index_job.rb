# Sidekiq defers scheduling to other, better suited gems.
# If you want to run a job regularly, here's an example
# of using the 'clockwork' gem to push jobs to Sidekiq
# regularly.

# require boot & environment for a Rails app
#require_relative "../config/boot"
require_relative "../../config/environment"
require "SphinxRakeSupport"
require "clockwork"


class SphinxIndexWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform
    Rails.logger.info "### Sphinx - Start Index"
    SphinxRakeSupport::Schedule.ts_index
    Rails.logger.info "### Sphinx - Index Completed"
    Log.write("SphinxIndex","Completed Sphinx-Reindex")
  end
end

module Clockwork
    every(10.seconds,'SphinxIndexWorker.perform_async') do
    SphinxIndexWorker.perform_async
  end
 end