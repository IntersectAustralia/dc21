require "spec_helper"

describe Notifier do
  
  describe "Email notifications to users should be sent" do
    it "should send mail to user if access request approved" do
      address = 'user@email.org'
      user = Factory(:user, :status => "A", :email => address)
      email = Notifier.notify_user_of_approved_request(user).deliver
  
      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false) 
      email.to.should eq([address])
      email.subject.should eq("DIVER - Your access request has been approved")
    end

    it "should send mail to user if access request denied" do
      address = 'user@email.org'
      user = Factory(:user, :status => "A", :email => address)
      email = Notifier.notify_user_of_rejected_request(user).deliver
  
      # check that the email has been queued for sending
      ActionMailer::Base.deliveries.empty?.should eq(false) 
      email.to.should eq([address])
      email.subject.should eq("DIVER - Your access request has been rejected")
    end

    it "should send mail to recipients if package published" do
      recipients = ["user@email.org","recipient1@email.org","recipient2@email.org"]
      pkg = Factory(:data_file, format: FileTypeDeterminer::BAGIT, access_rights_type: 'Open')
      email = Notifier.notify_recipients_of_successful_package_publish(pkg,recipients).deliver

      ActionMailer::Base.deliveries.empty?.should eq(false)
      email.to.should eq(recipients)
      email.subject.should eq("DIVER - Package publishing is successful")
    end

  end

  describe "Notification to superusers when new access request created"
  it "should send the right email" do
    address = 'user@email.org'
    user = Factory(:user, :status => "U", :email => address)
    User.should_receive(:get_superuser_emails) { ["super1@intersect.org.au", "super2@intersect.org.au"] }
    email = Notifier.notify_superusers_of_access_request(user).deliver

    # check that the email has been queued for sending
    ActionMailer::Base.deliveries.empty?.should eq(false)
    email.subject.should eq("DIVER - There has been a new access request")
    email.to.should eq(["super1@intersect.org.au", "super2@intersect.org.au"])
  end
 
end
