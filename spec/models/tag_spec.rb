require 'spec_helper'

describe Tag do
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it "should validate uniqueness of name, case insensitive" do
      Factory(:tag, :name => "blah")
      should validate_uniqueness_of(:name).case_insensitive
    end
  end
end
