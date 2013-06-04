require 'spec_helper'

describe User do
  describe "Associations" do
    it { should belong_to(:role) }
    it { should have_and_belong_to_many(:cart_items) }
  end

  describe "Named Scopes" do
    describe "Users Pending Approval Scope" do
      it "should return users that are unapproved ordered by email address" do
        u1 = Factory(:user, :status => 'U', :email => "fasdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'A')
        u3 = Factory(:user, :status => 'U', :email => "asdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'R')
        User.pending_approval.should eq([u3,u1])
      end
    end
    describe "Approved Users Scope" do
      it "should return users that are approved ordered by email address" do
        u1 = Factory(:user, :status => 'A', :email => "fasdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'U')
        u3 = Factory(:user, :status => 'A', :email => "asdf1@intersect.org.au")
        u4 = Factory(:user, :status => 'R')
        u5 = Factory(:user, :status => 'D')
        User.approved.should eq([u3,u1])
      end
    end
    describe "Deactivated or Approved Users Scope" do
      it "should return users that are approved ordered by email address" do
        u1 = Factory(:user, :status => 'A', :email => "fasdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'U')
        u3 = Factory(:user, :status => 'A', :email => "asdf1@intersect.org.au")
        u4 = Factory(:user, :status => 'R')
        u5 = Factory(:user, :status => 'D', :email => "zz@inter.org")
        User.deactivated_or_approved.should eq([u3,u1, u5])
      end
    end
    describe "Approved Administrators Scope" do
      it "should return users that are approved ordered by email address" do
        super_role = Factory(:role, :name => "Administrator")
        other_role = Factory(:role, :name => "Other")
        u1 = Factory(:user, :status => 'A', :role => super_role, :email => "fasdf1@intersect.org.au")
        u2 = Factory(:user, :status => 'A', :role => other_role)
        u3 = Factory(:user, :status => 'U', :role => super_role)
        u4 = Factory(:user, :status => 'R', :role => super_role)
        u5 = Factory(:user, :status => 'D', :role => super_role)
        User.approved_superusers.should eq([u1])
      end
    end
  end

  describe "Approve Access Request" do
    it "should set the status flag to A" do
      user = Factory(:user, :status => 'U')
      user.approve_access_request
      user.status.should eq("A")
    end
  end

  describe "Reject Access Request" do
    it "should set the status flag to R" do
      user = Factory(:user, :status => 'U')
      user.reject_access_request
      user.status.should eq("R")
    end
  end

  describe "Status methods and status description" do
    let(:active) {Factory(:user, :status => 'A')}
    let(:deactivated) {Factory(:user, :status => 'D')}
    let(:rejected) {Factory(:user, :status => 'R')}
    let(:pending_approval) {Factory(:user, :status => 'U')}
    it "should identify active users correctly" do
      active.approved?.should be_true
      active.pending_approval?.should be_false
      active.deactivated?.should be_false
      active.rejected?.should be_false
      active.status_description.should == "Active"
    end
    it "should identify deactivated users correctly" do
      deactivated.approved?.should be_false
      deactivated.pending_approval?.should be_false
      deactivated.deactivated?.should be_true
      deactivated.rejected?.should be_false
      deactivated.status_description.should == "Deactivated"
    end
    it "should identify rejected users correctly" do
      rejected.approved?.should be_false
      rejected.pending_approval?.should be_false
      rejected.deactivated?.should be_false
      rejected.rejected?.should be_true
      rejected.status_description.should == "Rejected"
    end
    it "should identify pending approval users correctly" do
      pending_approval.approved?.should be_false
      pending_approval.pending_approval?.should be_true
      pending_approval.deactivated?.should be_false
      pending_approval.rejected?.should be_false
      pending_approval.status_description.should == "Pending Approval"
    end

  end

  describe "Update password" do
    it "should fail if current password is incorrect" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "asdf", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_false
      user.errors[:current_password].should eq ["is invalid"]
    end
    it "should fail if current password is blank" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_false
      user.errors[:current_password].should eq ["can't be blank"]
    end
    it "should fail if new password and confirmation blank" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "", :password_confirmation => ""})
      result.should be_false
      user.errors[:password].should eq ["can't be blank", "must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"]
    end
    it "should fail if confirmation blank" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => ""})
      result.should be_false
      user.errors[:password].should eq ["doesn't match confirmation"]
    end
    it "should fail if confirmation doesn't match new password" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.678"})
      result.should be_false
      user.errors[:password].should eq ["doesn't match confirmation"]
    end
    it "should fail if password doesn't meet rules" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass4567", :password_confirmation => "Pass4567"})
      result.should be_false
      user.errors[:password].should eq ["must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"]
    end
    it "should succeed if current password correct and new password ok" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.456"})
      result.should be_true
    end
    it "should always blank out passwords" do
      user = Factory(:user, :password => "Pass.123")
      result = user.update_password({:current_password => "Pass.123", :password => "Pass.456", :password_confirmation => "Pass.456"})
      user.password.should be_blank
      user.password_confirmation.should be_blank
    end
  end

  describe "Find the number of superusers method" do
    it "should return true if there are at least 2 superusers" do
      super_role = Factory(:role, :name => 'Administrator')
      user_1 = Factory(:user, :role => super_role, :status => 'A', :email => 'user1@intersect.org.au')
      user_2 = Factory(:user, :role => super_role, :status => 'A', :email => 'user2@intersect.org.au')
      user_3 = Factory(:user, :role => super_role, :status => 'A', :email => 'user3@intersect.org.au')
      user_1.check_number_of_superusers(1, 1).should eq(true)
    end

    it "should return false if there is only 1 superuser" do
      super_role = Factory(:role, :name => 'Administrator')
      user_1 = Factory(:user, :role => super_role, :status => 'A', :email => 'user1@intersect.org.au')
      user_1.check_number_of_superusers(1, 1).should eq(false)
    end
    
    it "should return true if the logged in user does not match the user record being modified" do  
      super_role = Factory(:role, :name => 'Administrator')
      research_role = Factory(:role, :name => 'Researcher')
      user_1 = Factory(:user, :role => super_role, :status => 'A', :email => 'user1@intersect.org.au')
      user_2 = Factory(:user, :role => research_role, :status => 'A', :email => 'user2@intersect.org.au')
      user_1.check_number_of_superusers(1, 2).should eq(true)
    end
  end

  describe "Validations" do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }

    #password rules: at least one lowercase, uppercase, number, symbol
    # too short < 6
    it { should_not allow_value("AB$9a").for(:password) }
    # too long > 20
    it { should_not allow_value("Aa0$56789012345678901").for(:password) }
    # missing upper
    it { should_not allow_value("aaa000$$$").for(:password) }
    # missing lower
    it { should_not allow_value("AAA000$$$").for(:password) }
    # missing digit
    it { should_not allow_value("AAAaaa$$$").for(:password) }
    # missing symbol
    it { should_not allow_value("AAA000aaa").for(:password) }
    # ok
    it { should allow_value("AB$9aa").for(:password) }

    # check each of the possible symbols we allow
    it { should allow_value("AAAaaa000!").for(:password) }
    it { should allow_value("AAAaaa000@").for(:password) }
    it { should allow_value("AAAaaa000#").for(:password) }
    it { should allow_value("AAAaaa000$").for(:password) }
    it { should allow_value("AAAaaa000%").for(:password) }
    it { should allow_value("AAAaaa000^").for(:password) }
    it { should allow_value("AAAaaa000&").for(:password) }
    it { should allow_value("AAAaaa000*").for(:password) }
    it { should allow_value("AAAaaa000(").for(:password) }
    it { should allow_value("AAAaaa000)").for(:password) }
    it { should allow_value("AAAaaa000-").for(:password) }
    it { should allow_value("AAAaaa000_").for(:password) }
    it { should allow_value("AAAaaa000+").for(:password) }
    it { should allow_value("AAAaaa000=").for(:password) }
    it { should allow_value("AAAaaa000{").for(:password) }
    it { should allow_value("AAAaaa000}").for(:password) }
    it { should allow_value("AAAaaa000[").for(:password) }
    it { should allow_value("AAAaaa000]").for(:password) }
    it { should allow_value("AAAaaa000|").for(:password) }
    it { should allow_value("AAAaaa000\\").for(:password) }
    it { should allow_value("AAAaaa000;").for(:password) }
    it { should allow_value("AAAaaa000:").for(:password) }
    it { should allow_value("AAAaaa000'").for(:password) }
    it { should allow_value("AAAaaa000\"").for(:password) }
    it { should allow_value("AAAaaa000<").for(:password) }
    it { should allow_value("AAAaaa000>").for(:password) }
    it { should allow_value("AAAaaa000,").for(:password) }
    it { should allow_value("AAAaaa000.").for(:password) }
    it { should allow_value("AAAaaa000?").for(:password) }
    it { should allow_value("AAAaaa000/").for(:password) }
    it { should allow_value("AAAaaa000~").for(:password) }
    it { should allow_value("AAAaaa000`").for(:password) }
  end

  describe "Get superuser emails" do
    it "should find all approved superusers and extract their email address" do
      super_role = Factory(:role, :name => "Administrator")
      admin_role = Factory(:role, :name => "Admin")
      super_1 = Factory(:user, :role => super_role, :status => "A", :email => "a@intersect.org.au")
      super_2 = Factory(:user, :role => super_role, :status => "U", :email => "b@intersect.org.au")
      super_3 = Factory(:user, :role => super_role, :status => "A", :email => "c@intersect.org.au")
      super_4 = Factory(:user, :role => super_role, :status => "D", :email => "d@intersect.org.au")
      super_5 = Factory(:user, :role => super_role, :status => "R", :email => "e@intersect.org.au")
      admin = Factory(:user, :role => admin_role, :status => "A", :email => "f@intersect.org.au")

      supers = User.get_superuser_emails
      supers.should eq(["a@intersect.org.au", "c@intersect.org.au"])
    end
  end

  describe 'Checking if a file is already in the cart' do
    it 'should check if the file is in the users cart' do
      user = Factory(:user)
      data_file_1 = Factory(:data_file)
      data_file_2 = Factory(:data_file)
      user.cart_items << data_file_1
      user.reload

      user.cart_items.include?(data_file_1).should be_true
      user.cart_items.include?(data_file_2).should be_false
    end
  end
  
end
