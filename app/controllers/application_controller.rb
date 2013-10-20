class ApplicationController < ActionController::Base
  rescue_from DeviseShibbolethAuthenticatable::ShibbolethException do |exception|
    render :text => exception, :status => 500
  end
  prepend_before_filter :retrieve_aaf_credentials

  before_filter :shib_sign_up, :except => :root

  def retrieve_aaf_credentials
    @aaf_credentials = {email: request.headers['email'], first_name: request.headers['givenName'], last_name: request.headers['surname'], exists: User.find_by_email(request.headers['email']).present?}
  end

  def shib_sign_up
    if !user_signed_in? && @aaf_credentials[:email].present? && User.find_by_email(@aaf_credentials[:email]).blank?
      redirect_to new_user_registration_path, alert: "You must be an approved user to access this site."
    end
  end

  protect_from_forgery
  before_filter :authenticate_user!

  expose(:cart_items) { current_user.present? ? current_user.cart_items : [] }

  # catch access denied and redirect to the home page
  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = exception.message
    redirect_to root_url
  end

end
