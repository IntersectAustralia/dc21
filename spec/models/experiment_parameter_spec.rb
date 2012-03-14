require 'spec_helper'

describe ExperimentParameter do
  describe "Associations" do
    it { should belong_to(:experiment) }
    it { should belong_to(:parameter_category) }
    it { should belong_to(:parameter_sub_category) }
    it { should belong_to(:parameter_modification) }
    it { should belong_to(:parameter_unit) }
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

  describe "Scopes" do
    it "get in order should sort by category, then subcategory, then modification" do
      cat_b = Factory(:parameter_category, :name => "Bear")
      cat_a = Factory(:parameter_category, :name => "Anteater")
      subcat_a = Factory(:parameter_sub_category, :parameter_category => cat_a, :name => "Grizzly")
      subcat_b = Factory(:parameter_sub_category, :parameter_category => cat_a, :name => "Polar")
      mod_b = Factory(:parameter_modification, :name => "B")
      mod_a = Factory(:parameter_modification, :name => "A")

      a_b_a = Factory(:experiment_parameter, :parameter_category => cat_a, :parameter_sub_category => subcat_b, :parameter_modification => mod_a)
      b_a_a = Factory(:experiment_parameter, :parameter_category => cat_b, :parameter_sub_category => subcat_a, :parameter_modification => mod_a)
      a_a_a = Factory(:experiment_parameter, :parameter_category => cat_a, :parameter_sub_category => subcat_a, :parameter_modification => mod_a)
      a_b_b = Factory(:experiment_parameter, :parameter_category => cat_a, :parameter_sub_category => subcat_b, :parameter_modification => mod_b)
      a_a_b = Factory(:experiment_parameter, :parameter_category => cat_a, :parameter_sub_category => subcat_a, :parameter_modification => mod_b)

      ExperimentParameter.in_order.collect(&:id).should eq([a_a_a.id, a_a_b.id, a_b_a.id, a_b_b.id, b_a_a.id])
    end
  end
end
