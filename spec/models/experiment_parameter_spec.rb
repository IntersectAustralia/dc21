require 'spec_helper'

describe ExperimentParameter do
  describe "Associations" do
    it { should belong_to(:experiment) }
    it { should belong_to(:parameter_category) }
    it { should belong_to(:parameter_sub_category) }
    it { should belong_to(:parameter_modification) }
  end

  describe "Validations" do
    it "can be created with minimal fields filled in" do
      ExperimentParameter.create!(experiment: Factory(:experiment),
                                  parameter_category: Factory(:parameter_category),
                                  parameter_sub_category: Factory(:parameter_sub_category),
                                  parameter_modification: Factory(:parameter_modification))
    end

    it { should validate_presence_of(:experiment) }
    it { should validate_presence_of(:parameter_category) }
    it { should validate_presence_of(:parameter_sub_category) }
    it { should validate_presence_of(:parameter_modification) }
  end
end
