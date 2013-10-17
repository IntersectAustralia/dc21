class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!, :set_system_name

  def set_system_name
    @config = SystemConfiguration.instance
  end

  expose(:cart_items) { current_user.present? ? current_user.cart_items : [] }
  
  # catch access denied and redirect to the home page
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end

end
