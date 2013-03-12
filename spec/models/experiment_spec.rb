require 'spec_helper'

describe Experiment do

  describe "Associations" do
    it { should belong_to(:facility) }
    it { should belong_to(:parent_experiment) }
    it { should have_many(:experiment_for_codes) }
    it { should have_many(:experiment_parameters) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:facility_id) }
    it { should validate_presence_of(:access_rights) }
    it { should ensure_length_of(:name).is_at_most 255 }
    it { should ensure_length_of(:description).is_at_most 8192 }
    it { should ensure_length_of(:subject).is_at_most 255 }

    describe "should validate that end date is on or after start date (unless end date blank)" do
      it "should allow end date on start date" do
        Factory.build(:experiment, :start_date => "2011-12-01", :end_date => "2011-12-01").should be_valid
      end

      it "should allow end date after start date" do
        Factory.build(:experiment, :start_date => "2011-12-01", :end_date => "2011-12-02").should be_valid
      end

      it "should allow start date on nil end date" do
        Factory.build(:experiment, :start_date => "2011-12-01", :end_date => nil).should be_valid
      end
    end
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

  describe "Setting FOR codes" do
    it "should remove any existing codes" do
      experiment = Factory(:experiment)
      experiment.experiment_for_codes.create!(:name => "A", :url => "myurl")
      experiment.set_for_codes({"1" => {"name" => "B", "url" => "burl"}, "2" => {"name" => "C", "url" => "curl"}})
      experiment.experiment_for_codes.collect { |efc| [efc.name, efc.url] }.should eq([["B", "burl"], ["C", "curl"]])
      #check its still ok after reload
      experiment.save
      experiment.reload
      experiment.experiment_for_codes.collect { |efc| [efc.name, efc.url] }.should eq([["B", "burl"], ["C", "curl"]])
    end

    it "should ignore duplicates" do
      experiment = Factory(:experiment)
      experiment.set_for_codes({"1" => {"name" => "B", "url" => "burl"}, "2" => {"name" => "C", "url" => "curl"}, "3" => {"name" => "C", "url" => "curl"}})
      experiment.experiment_for_codes.collect { |efc| [efc.name, efc.url] }.should eq([["B", "burl"], ["C", "curl"]])
    end
  end

  describe "Get access right name" do
    it "should look it up in the access rights lookup" do
      Factory(:experiment, :access_rights => "http://creativecommons.org/licenses/by/3.0/au").access_rights_description.should eq("CC BY: Attribution")
    end

    it "should return nil if not found" do
      Factory(:experiment, :access_rights => "blah").access_rights_description.should be_nil
    end
  end

end
