class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!

  layout :layout_by_resource

  def layout_by_resource
    if devise_controller?
      "guest"
    else
      "application"
    end
  end



  # catch access denied and redirect to the home page
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end

end

##########################################
# TabBuilders have been moved to lib/tab_builders.rb (and included in application_helper)
##########################################
