class Notifier < ActionMailer::Base

  PREFIX = "HIEv - "

  def notify_user_of_approved_request(recipient)
    @user = recipient
    mail( :to => @user.email, 
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => PREFIX + "Your access request has been approved")
  end

  def notify_user_of_rejected_request(recipient)
    @user = recipient
    mail( :to => @user.email, 
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => PREFIX + "Your access request has been rejected")
  end

  # notifications for super users
  def notify_superusers_of_access_request(applicant)
    superusers_emails = User.get_superuser_emails
    @user = applicant
    mail( :to => superusers_emails,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => @user.email,
          :subject => PREFIX + "There has been a new access request")
  end

  def notify_user_that_they_cant_reset_their_password(user)
    @user = user
    mail( :to => @user.email,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => PREFIX + "Reset password instructions")
  end

  def notify_user_of_completed_package(package)
    @user = package.created_by
    @package = package
    mail( :to => @user.email,
          :from => APP_CONFIG['notification_email_sender'],
          :reply_to => APP_CONFIG['notification_email_sender'],
          :subject => PREFIX + "Package completed")
  end

end
