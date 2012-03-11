require 'spec_helper'

describe ParameterCategory do
  describe "Validations" do
    it "object is valid with the basic info filled" do
      ParameterCategory.new(name: "Blah").should be_valid
    end

    it { should validate_presence_of(:name) }
  end

  describe "Associations" do
    it { should have_many(:parameter_sub_categories) }
  end
end
