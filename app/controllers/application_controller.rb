class ApplicationController < ActionController::Base
  rescue_from DeviseAafRcAuthenticatable::AafRcException do |exception|
    render :text => exception, :status => 500
  end
  before_filter :aaf_sign_up_redirect, except: [:root, :destroy]
  before_filter :aaf_flash, except: :destroy
  prepend_before_filter :retrieve_aaf_credentials, except: :destroy

  def aaf_flash
    if !user_signed_in? && @aaf_mail.present?
      if User.find_for_authentication(email: @aaf_mail).blank?
        flash.now[:alert] = t 'devise.failure.invalid_aaf'
      else
        flash.now[:alert] = t 'devise.failure.inactive'
      end
    end
  end

  def aaf_sign_up_redirect
    # Edge case for DIVER so that it redirects to sign up page.
    if !user_signed_in? && (params[:assertion].present? || (@aaf_mail.present? && User.find_for_authentication(email: @aaf_mail).blank?))
      redirect_to new_user_registration_path
    end
  end

  def retrieve_aaf_credentials
    @aaf_credentials = session['attributes'] || {}
    @aaf_mail = @aaf_credentials[:mail]
    @aaf_first_name = @aaf_credentials[:givenname]
    @aaf_last_name = @aaf_credentials[:surname]
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


  before_filter :clean_select_multiple_params

  def clean_select_multiple_params hash = params
    hash.each do |k, v|
      case v
      when Array then v.reject!(&:blank?)
      when Hash then clean_select_multiple_params(v)
      end
    end
  end

end
