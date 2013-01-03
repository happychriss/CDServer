
class SearchController < ApplicationController

  def search
    @current_keywords||= []
  end

  def found

    session[:search_results] = request.url

    @current_keywords=params[:document].nil? ? []:params[:document][:keyword_list]

    @pages=Page.search_index(params[:q],@current_keywords, params[:page])

    @q=params[:q]

    render :action => 'search'

end

end



