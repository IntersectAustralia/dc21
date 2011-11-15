class PagesController < ApplicationController
  skip_before_filter :authenticate_user!

  # if there's some other layout that's better for these pages
  #layout 'overview' 


  def routing_error
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end


  def home
    render :layout => 'guest' and return unless user_signed_in?
    set_tab :home
    set_tab :dashboard, :adminnavigation
  end

  def explore
    render :layout => 'guest' and return unless user_signed_in?
    set_tab :home
    set_tab :explore, :adminnavigation
  end
end
