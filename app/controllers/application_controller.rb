class ApplicationController < ActionController::Base
  rescue_from DeviseShibbolethAuthenticatable::ShibbolethException do |exception|
    render :text => exception, :status => 500
  end
  prepend_before_filter :retrieve_aaf_credentials

  before_filter :shib_sign_up_redirect, :except => :root
  before_filter :shib_flash

  def retrieve_aaf_credentials
    @aaf_credentials = {email: request.headers['email'], first_name: request.headers['givenName'], last_name: request.headers['surname'], exists: User.find_by_email(request.headers['email']).present?}
  end

  def shib_flash
    if !user_signed_in? && @aaf_credentials[:email].present? && User.find_by_email(@aaf_credentials[:email]).blank?
      flash.now[:alert] = t "devise.failure.invalid_aaf"
    else
      flash.now[:alert] = t "devise.failure.inactive"
    end
  end

  def shib_sign_up_redirect
    if !user_signed_in? && @aaf_credentials[:email].present? && User.find_by_email(@aaf_credentials[:email]).blank?
      redirect_to new_user_registration_path
    end
  end

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
