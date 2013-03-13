class PagesController < ApplicationController
  skip_before_filter :authenticate_user!

  def routing_error
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  def home
    if !user_signed_in?
      set_tab :login
      render :layout => 'application'
    else
      set_tab :home
      set_tab :dashboard, :contentnavigation
      @data_files = DataFile.most_recent_first.limit(5)
      @unadded_items = false
      @data_files.each do |data_file|
        unless current_user.data_file_in_cart?(data_file)
          @unadded_items = true
        end
      end
      render :layout => 'data_files'
    end
  end

  def route_404
    raise ActionController::RoutingError.new('Not Found')
    #render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  def route_422
    render :file => "#{Rails.root}/public/422.html", :status => 422
  end

  def route_500
    render :file => "#{Rails.root}/public/500.html", :status => 500
  end

  private

end
