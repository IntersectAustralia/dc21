class PagesController < ApplicationController:
  
 layout 'overview'

 def home
   render :layout => 'guest' and return unless user_signed_in?

   if @memberships.count.eql?(1)
     redirect_to system_path(@memberships.first)
   end

 end

 def routing_error
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end


  def home
    set_tab :home
    set_tab :dashboard, :adminnavigation
  end
  def explore
    set_tab :home
    set_tab :explore, :adminnavigation
  end
end
