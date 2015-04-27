class UserRegistersController < Devise::RegistrationsController

  set_tab :signup

  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy, :edit_password, :update_password, :profile]
  layout 'application'

  skip_before_filter :shib_sign_up_redirect, :only => [:new, :create]
  def profile
    set_tab :account
    set_tab :overview, :contentnavigation
  end

  def edit
    set_tab :account
    set_tab :editdetails, :contentnavigation
  end

  # Override the create method in the RegistrationsController to add the notification hook
  # https://github.com/plataformatec/devise/blob/v1.3.4/app/controllers/devise/registrations_controller.rb
  def create

    build_resource

    if resource.save
      Notifier.notify_superusers_of_access_request(resource).deliver
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => redirect_location(resource_name, resource)
      else
        set_flash_message :notice, :inactive_signed_up, :reason => resource.inactive_message.to_s if is_navigational_format?
        expire_session_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource) { render :new }
    end
  end

  # Override the update method in the RegistrationsController so that we don't require password on update
  # https://github.com/plataformatec/devise/blob/v1.3.4/app/controllers/devise/registrations_controller.rb
  def update
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource){ render :edit }
    end
  end

  def edit_password
    set_tab :account
    set_tab :changepassword, :contentnavigation
    render :edit_password
  end

  # Mostly the same as the devise 'update' method, just call a different method on the model
  def update_password
    set_tab :account
    set_tab :changepassword, :contentnavigation
    if resource.update_password(params[resource_name])
      set_flash_message :notice, :password_updated if is_navigational_format?
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      respond_with_navigational(resource){ render :edit_password }
    end
  end

  def generate_token
    current_user.reset_authentication_token!
    redirect_to users_profile_path, :notice => "Your new API token is shown below."
  end

  def delete_token
    current_user.authentication_token = nil
    current_user.save!
    redirect_to users_profile_path, :notice => "Your API token has been deleted."
  end

  protected
  def after_update_path_for(resource)
    users_profile_path
  end

end
