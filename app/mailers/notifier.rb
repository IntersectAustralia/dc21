class Notifier < ActionMailer::Base

  def system_name
    config = Proc.new { return SystemConfiguration.instance.name }
    config.call
  end

  def notify_user_of_approved_request(recipient)
    @user = recipient
    @system_name = system_name
    mail( :to => @user.email,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => "#{system_name} - Your access request has been approved")
  end

  def notify_user_of_rejected_request(recipient)
    @user = recipient
    @system_name = system_name
    mail( :to => @user.email,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => "#{system_name} - Your access request has been rejected")
  end

  # notifications for super users
  def notify_superusers_of_access_request(applicant)
    superusers_emails = User.get_superuser_emails
    @user = applicant
    @system_name = system_name
    mail( :to => superusers_emails,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => @user.email,
          :subject => "#{system_name} - There has been a new access request")
  end

  def notify_user_that_they_cant_reset_their_password(user)
    @user = user
    @system_name = system_name
    mail( :to => @user.email,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => "#{system_name} - Reset password instructions")
  end

  def notify_user_of_completed_package(package)
    @user = package.created_by
    @system_name = system_name
    @package = package
    mail( :to => @user.email,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => "#{system_name} - Package completed")
  end

  def notify_user_of_completed_processing(data_file)
    @user = data_file.created_by
    @system_name = system_name
    @data_file = data_file
    mail( :to => @user.email,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => "#{system_name} - Processing completed")
  end

  def notify_user_reset_password_instructions(recipient)
    @user = recipient
    @system_name = system_name
    mail( :to => @user.email,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => "#{system_name} - Reset password instructions")
  end

  def notify_recipients_of_successful_package_publish(package, recipients)
    @system_name = system_name
    @package = package
    mail(:to =>recipients,
        :from => APP_CONFIG['notification_email_sender'],
        :reply_to => APP_CONFIG['notification_email_sender'],
        :subject => "#{system_name} - Package publishing is successful")
  end

  def notify_recipients_of_failed_package_publish(package, recipients)
    @system_name = system_name
    @package = package
    mail(:to => recipients,
         :from => APP_CONFIG['notification_email_sender'],
         :reply_to => APP_CONFIG['notification_email_sender'],
         :subject => "#{system_name} - Package publishing has failed")
  end

end
