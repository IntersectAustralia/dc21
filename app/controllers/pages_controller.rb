class PagesController < ApplicationController
  skip_before_filter :authenticate_user!

  # if there's some other layout that's better for these pages
  #layout 'overview' 

  def routing_error
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end


  def home
    if !user_signed_in?
      set_tab :login
      render :layout => 'guest' and return
    else
      set_tab :home
      set_tab :dashboard, :contentnavigation
      @data_files = DataFile.most_recent_first.limit(5)
    end
  end

  def about
      set_tab :about
  end

end
