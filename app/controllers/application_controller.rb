class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  layout :layout_by_resource

  # catch access denied and redirect to the home page
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end

  protected
    #This method is designed to capture the devise login and present it with the appropriate layout
  def layout_by_resource
    if devise_controller?
      "guest"
    else
      default_layout
    end
  end

  #This method should be overridden in child classes
  def default_layout
    "application"
  end


end

##########################################
# TabBuilders have been moved to lib/tab_builders.rb (and included in application_helper)
##########################################
