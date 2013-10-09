module Pusher

  def push_status_update
    message= render_anywhere('/app_status')
    PrivatePub.publish_to("/app_status", message)
  end

  def push_converted_page(page)
    message= render_anywhere('/upload_sorting/converted_page', {:page => page})
    logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Publish: #{message}"
    PrivatePub.publish_to("/converted_page", message)
  end

  private

  def render_anywhere(partial, locals= {}, assigns = {})
    view = ActionView::Base.new(ActionController::Base.view_paths, assigns)
    view.extend ApplicationHelper
    view.render(:partial => partial, :locals => locals, :formats => [:erb])
  end

end

