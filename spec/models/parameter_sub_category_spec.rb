require 'spec_helper'

describe ParameterSubCategory do

  describe "Validations" do
    it "the object is valid with basic data filled in" do
      ParameterSubCategory.new(name: "Blah", parameter_category: Factory(:parameter_category)).should be_valid
    end

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:parameter_category) }
  end

  describe "Associations" do
    it { should belong_to(:parameter_category) }
  end

end
