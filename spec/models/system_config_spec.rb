require 'spec_helper'

describe SystemConfiguration do
#EYETRACKER-1
  describe "Update system config fields" do
    it "should fail if no local system name is given" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:name => ""})
      result.should be_false
      config.errors[:name].should eq ["can't be blank"]
    end

    it "should fail if no research centre name is given" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:research_centre_name => ""})
      result.should be_false
      config.errors[:research_centre_name].should eq ["can't be blank"]
    end

    it "should fail if no entity is given" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:entity => ""})
      result.should be_false
      config.errors[:entity].should eq ["can't be blank"]
    end

    it "should fail if local system name is longer than 20 characters" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:name => "qwertyuioplkjhgfdsazx"})
      result.should be_false
      config.errors[:name].should eq ["is too long (maximum is 20 characters)"]
    end

    it "should fail if research centre name is longer than 80 characters" do
      config = SystemConfiguration.instance
      long_name = 'a' * 81
      result = config.update_attributes({:research_centre_name => long_name})
      result.should be_false
      config.errors[:research_centre_name].should eq ["is too long (maximum is 80 characters)"]
    end

    it "should pass if system name contains special characters" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:name => '<>?/.,:', :description => '+_)(*&^%$#@!`~17-=][{}|:;?>\\<,./`'})
      result.should be_true
    end

    it "should fail if email is not valid" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:email => 'invalid_email'})
      result.should be_false
      config.errors[:email].should eq ["is not an email"]
    end

    #it "should fail if telephone is not a number" do
    #  config = SystemConfiguration.instance
    #  result = config.update_attributes({:telephone_number => 'not a number'})
    #  result.should be_false
    #  config.errors[:telephone_number].should eq ["is not a valid phone number"]
    #end
  end
end
