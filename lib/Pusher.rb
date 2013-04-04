
module Pusher


  private

  def render_anywhere(partial,locals= {}, assigns = {})
    logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! partial: #{partial}"
    logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! locals #{locals}"
    view = ActionView::Base.new(ActionController::Base.view_paths, assigns)
    view.extend ApplicationHelper
    view.render(:partial => partial, :locals => locals)

  end

  def push_status_update
#    message= render_anywhere('/app_status.js.erb', {:worker_message =>"hihi"})
    message= render_anywhere('/app_status.js.erb')
    PrivatePub.publish_to("/app_status", message)
#  logger.info "Publish: #{message}"

  end

  def push_converted_page(page)

    logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Value: #{page.id}"
    message= render_anywhere('/upload_sorting/converted_page.js.erb', {:page => page})
    logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Publish: #{message}"
#    message= render_anywhere('/app_status.js.erb')

    PrivatePub.publish_to("/converted_page", message)


  end

end