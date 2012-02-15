require 'spec_helper'

describe Experiment do
  describe "Associations" do
    it { should belong_to(:facility) }
    it { should belong_to(:parent_experiment) }
    it { should have_many(:experiment_for_codes) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:facility_id) }
  end

  describe "Name with prefix method" do
    it "should add 'Experiment - ' to the front of the name" do
      Factory(:experiment, :name => "Fred").name_with_prefix.should eq("Experiment - Fred")
    end
  end

  describe "Parent name method" do
    it "should return the facility if there's no parent experiment set" do
      exp = Factory(:experiment, :facility => Factory(:facility, :name => "My Facility"), :parent_experiment => nil)
      exp.parent_name.should eq("Facility - My Facility")
    end
    it "should return the experiment if there's a parent experiment set" do
      exp = Factory(:experiment, :facility => Factory(:facility, :name => "My Facility"), :parent_experiment => Factory(:experiment, :name => "My Parent"))
      exp.parent_name.should eq("Experiment - My Parent")
    end
  end
end
