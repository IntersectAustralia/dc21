class UserSessionsController < Devise::SessionsController
  skip_before_filter :shib_sign_up
  def aaf_new
    resource = build_resource
    shib_config = YAML.load(ERB.new(File.read(::Devise.shibboleth_config || "#{Rails.root}/config/shibboleth.yml")).result)[Rails.env]

    destination = request.protocol
    destination << request.host
    destination << ":#{request.port.to_s}" unless request.port == 80
    destination << after_sign_in_path_for(resource)

    shib_login_url = shib_config['shibb_login_url'] + "?target=" + URI.escape(destination, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    redirect_to(shib_login_url)
  end

  def aaf_destroy
    resource = build_resource
    shib_config = YAML.load(ERB.new(File.read(::Devise.shibboleth_config || "#{Rails.root}/config/shibboleth.yml")).result)[Rails.env]

    destination = request.protocol
    destination << request.host
    destination << ":#{request.port.to_s}" unless request.port == 80
    destination << destroy_user_session_path

    shib_logout_url = shib_config['shibb_login_url'].sub(/Login/, "Logout") + "?return=" + URI.escape(destination, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))

    redirect_to(shib_logout_url)
  end

end
