class UserPasswordsController < Devise::PasswordsController

  def create
    # Override the devise controller so we don't show errors (since we don't want to reveal if the email exists)
    # https://github.com/plataformatec/devise/blob/v1.4.2/app/controllers/devise/passwords_controller.rb
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    # the only error we show is the empty email one
    if params[resource_name][:email].empty?
      respond_with_navigational(resource){ render :new }
    else
      set_flash_message(:notice, :send_paranoid_instructions) if is_navigational_format?
      redirect_to(new_user_session_path)
    end
  end

end