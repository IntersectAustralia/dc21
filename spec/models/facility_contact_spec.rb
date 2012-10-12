require 'spec_helper'

describe FacilityContact do

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:facility) }
  end

  describe "Validation" do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:facility) }
  end

end
