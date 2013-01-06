require 'spec_helper'

describe CartItem do
  describe "Create valid object" do
    it "creating an object with the minimum fields should succeed" do
      Factory(:cart_item).should be_valid
    end
  end

  describe "Associations" do
    it { should have_one(:data_file) }
    it { should have_one(:user) }
  end

  describe "Validations" do
    it { should validate_presence_of(:data_file_id) }
    it { should validate_presence_of(:user_id) }

    it "should validate uniqueness of data_file/user_id combination" do
      Factory(:facility)
      should_validate_uniqueness_of (:data_file_id, :scoped_to => :user_id)
    end
  end

end