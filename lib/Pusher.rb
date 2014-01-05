module Pusher

  def push_status_update
    message= render_anywhere('/app_status')
    PrivatePub.publish_to("/app_status", message)
    puts "*********: Remote Status: #{DaemonConverter.instance.connected?}"
  end

  def push_converted_page(page,local_conversion = false)
    message= render_anywhere('/upload_sorting/converted_page', {:page => page, :local_conversion => local_conversion})
    logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Publish: #{message}"
    PrivatePub.publish_to("/converted_page", message)
  end

  private

  def render_anywhere(partial, locals= {}, assigns = {})
    view = ActionView::Base.new(ActionController::Base.view_paths, assigns)
    view.extend ApplicationHelper
    view.render(:partial => partial, :locals => locals, :formats => [:js], :handlers => [:erb])
  end

end

