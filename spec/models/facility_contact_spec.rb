require 'spec_helper'

describe FacilityContact do
  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:facility) }
  end

  describe "Validation" do
    let(:user1) { Factory(:user, :login => "user1") }
    let(:user2) { Factory(:user, :login => "user2") }
    let(:fac1)  { Factory(:facility, :primary_contact => user1) }
    let(:fac2)  { Factory(:facility, :primary_contact => user2) }

    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:facility) }

    it { should validate_uniqueness_of(:primary).scoped_to(:facility) }
  end

  describe "Scopes" do
    it "should have the scopes refactored from Facility into FacilityContact" do
      pending "But I'm still getting the tests to pass before refactoring'"
    end
  end
 
end
