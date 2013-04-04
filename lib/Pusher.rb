module Pusher

  def push_status_update
    message= render_anywhere('/app_status.js.erb')
    PrivatePub.publish_to("/app_status", message)
  end

  def push_converted_page(page)
    message= render_anywhere('/upload_sorting/converted_page.js.erb', {:page => page})
    # GOOD FOR DEBUGGING    logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Publish: #{message}"
    PrivatePub.publish_to("/converted_page", message)
  end

  private

  def render_anywhere(partial, locals= {}, assigns = {})
    view = ActionView::Base.new(ActionController::Base.view_paths, assigns)
    view.extend ApplicationHelper
    view.render(:partial => partial, :locals => locals)
  end

end