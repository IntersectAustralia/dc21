require 'spec_helper'

describe SystemConfiguration do
#EYETRACKER-1
  long_name = 'a' * 81

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

    it "should fail if no organisational level 1 is given" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:level1 => ""})
      result.should be_false
      config.errors[:level1].should eq ["can't be blank"]

      result = config.update_attributes({:level1_plural => ""})
      result.should be_false
      config.errors[:level1_plural].should eq ["can't be blank"]
    end

    it "should fail if no organisational level 2 is given" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:level2 => ""})
      result.should be_false
      config.errors[:level2].should eq ["can't be blank"]

      result = config.update_attributes({:level2_plural => ""})
      result.should be_false
      config.errors[:level2_plural].should eq ["can't be blank"]
    end

    it "should fail if local system name is longer than 20 characters" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:name => "qwertyuioplkjhgfdsazx"})
      result.should be_false
      config.errors[:name].should eq ["is too long (maximum is 20 characters)"]
    end

    it "should fail if research centre name is longer than 80 characters" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:research_centre_name => long_name})
      result.should be_false
      config.errors[:research_centre_name].should eq ["is too long (maximum is 80 characters)"]
    end

    it "should pass if system name contains special characters" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:name => '<>?/.,:', :description => '+_)(*&^%$#@!`~17-=][{}|:;?>\\<,./`'})
      result.should be_true
      config.errors[:email].should be_empty
    end

    it "should fail if email is not valid" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:email => 'invalid_email'})
      result.should be_false
      config.errors[:email].should eq ["is invalid"]
    end

    it "should pass if email is blank" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:email => ''})
      result.should be_true
      config.errors[:email].should be_empty
    end

    it "should fail if org level2 value equals level1" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:level1 => 'same name', :level2 => 'same name'})
      result.should be_false
      config.errors[:level1].should eq ["cannot be the same as Type of Project (Singular)"]

      result = config.update_attributes({:level1_plural => 'same name'})
      result.should be_false
      config.errors[:level1_plural].should eq ["cannot be the same as Type of Project (Singular)"]
    end

    it "should fail if a line in the address field is longer than 80 characters" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:address1 => long_name})
      result.should be_false
      config.errors[:address1].should eq ["is too long (maximum is 80 characters)"]

      result = config.update_attributes({:address2 => long_name})
      result.should be_false
      config.errors[:address2].should eq ["is too long (maximum is 80 characters)"]

      result = config.update_attributes({:address3 => long_name})
      result.should be_false
      config.errors[:address3].should eq ["is too long (maximum is 80 characters)"]
    end

    it "should pass if address is blank" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:address1 => ''})
      result.should be_true
      config.errors[:address1].should be_empty

      config = SystemConfiguration.instance
      result = config.update_attributes({:address2 => ''})
      result.should be_true
      config.errors[:address2].should be_empty

      config = SystemConfiguration.instance
      result = config.update_attributes({:address3 => ''})
      result.should be_true
      config.errors[:address3].should be_empty
    end
    it "should fail if URL is longer than 80 characters" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:urls => long_name})
      result.should be_false
      config.errors[:urls].should eq ["is too long (maximum is 80 characters)"]
    end

    it "should pass if URLs is blank" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:urls => ''})
      result.should be_true
      config.errors[:urls].should be_empty
    end

    it "should pass if telephone number is blank" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:telephone_number => ''})
      result.should be_true
      config.errors[:telephone_number].should be_empty
    end

    it "should pass if description is blank" do
      config = SystemConfiguration.instance
      result = config.update_attributes({:description => ''})
      result.should be_true
      config.errors[:description].should be_empty
    end

    #EYETRACKER-186
    it "should match lower or upper case filenames to regular expression" do
      config = SystemConfiguration.instance
      config.update_attributes({:auto_ocr_on_upload => true, :auto_ocr_regex => 'tEsT', :auto_sr_on_upload => true, :auto_sr_regex => 'MP3'})
      ocr_df = Factory.create(:data_file, :filename => 'TeSt1234.jpg', :format => 'image/jpeg')
      ocr_df2 = Factory.create(:data_file, :filename => 'blaTEST678.png', :format => 'image/png')
      sr_df = Factory.create(:data_file, :filename => 'abcdefg.mp3', :format => 'audio/mpeg')
      sr_df2 = Factory.create(:data_file, :filename => 'AbcTest.mp3', :format => 'audio/x-wav')

      config.auto_ocr?(ocr_df).should be_true
      config.auto_ocr?(ocr_df2).should be_true
      config.auto_sr?(sr_df).should be_true
      config.auto_sr?(sr_df2).should be_true
    end
  end
end
