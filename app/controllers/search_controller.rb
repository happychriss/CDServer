
class SearchController < ApplicationController

  def search

  end

  def found

    keyword_list=params[:document].nil? ? (nil):params[:document][:keyword_list]

    @pages=Document.get_matching_pages(params[:q],keyword_list, params[:page])

    @pages = @pages.paginate(:page => params[:page]) unless @pages.nil?

    @q=params[:q]
    @current_keyword_names=keyword_list

  render :action => 'search'

end

end



