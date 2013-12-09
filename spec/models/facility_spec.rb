require 'spec_helper'

describe Facility do
  describe "Create valid object" do
    it "creating an object with the minimum fields should succeed" do
      Factory(:facility).should be_valid
    end
  end

  describe "Associations" do
    it { should have_many(:experiments) }
    it { should have_many(:aggregated_contactables) }
    it { should have_one(:primary_contactable) }
    it { should have_one(:primary_contact) }
    it { should have_many(:contactables) }
    it { should have_many(:contacts) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should ensure_length_of(:name).is_at_most 50 }
    it { should ensure_length_of(:code).is_at_most 50 }

    it "should validate uniqueness of name" do
      Factory(:facility)
      should validate_uniqueness_of(:name)
    end

    it "should validate uniqueness of code" do
      Factory(:facility)
      should validate_uniqueness_of(:code)
    end

    it { should validate_presence_of(:primary_contact) }

    it "should, validate that lat/longs are filled as pairs" do
      Factory.build(:facility, :a_lat => 5).should_not be_valid
      Factory.build(:facility, :a_long => 5).should_not be_valid
      Factory.build(:facility, :b_lat => 5).should_not be_valid
      Factory.build(:facility, :b_long => 5).should_not be_valid
      Factory.build(:facility, :a_lat => 5, :a_long => 10, :b_long => 5).should_not be_valid
      Factory.build(:facility, :b_lat => 5, :b_long => 10, :a_long => 5).should_not be_valid

      Factory.build(:facility, :a_lat => 5, :a_long => 10).should be_valid
      Factory.build(:facility, :b_lat => 5, :b_long => 10).should be_valid
      Factory.build(:facility, :a_lat => 5, :a_long => 10, :b_lat => 5, :b_long => 10).should be_valid
    end

    it "should validate that latitudes/longitudes are numbers" do
      should validate_numericality_of(:a_lat).with_message("must be a number between -90 and 90")
      should validate_numericality_of(:b_lat).with_message("must be a number between -90 and 90")
      should validate_numericality_of(:a_long).with_message("must be a number between -180 and 180")
      should validate_numericality_of(:b_long).with_message("must be a number between -180 and 180")
    end

    it "should validate that latitudes/longitudes are within the allowed ranges" do
      should ensure_inclusion_of(:a_lat).in_range(-90..90).with_message("must be a number between -90 and 90")
      should ensure_inclusion_of(:a_long).in_range(-180..180).with_message("must be a number between -180 and 180")
      should ensure_inclusion_of(:b_lat).in_range(-90..90).with_message("must be a number between -90 and 90")
      should ensure_inclusion_of(:b_long).in_range(-180..180).with_message("must be a number between -180 and 180")
    end

  end

  describe "Description length" do
    it "should truncate when the field is over 10 kilobytes" do
      fac = Factory.create(:facility, :description => "x" * 20000)
      fac.description.length.should eq 10240
      Factory.build(:facility, :description => "x" * 10240).should be_valid
    end
  end

  describe "Fixing location entry" do
    it "Should switch the values if B values are filled but A are not on save" do
      record = Factory.build(:facility, :b_lat => 50, :b_long => 30, :a_lat => "", :a_long => "")
      record.save!
      record.b_lat.should be_blank
      record.a_lat.should eq(50)
      record.b_long.should be_blank
      record.a_long.should eq(30)
    end

    it "Should leave as is if both A and B values are filled" do
      record = Factory.build(:facility, :b_lat => 50, :b_long => 30, :a_lat => 20, :a_long => 10)
      record.save!
      record.b_lat.should eq(50)
      record.a_lat.should eq(20)
      record.b_long.should eq(30)
      record.a_long.should eq(10)
    end
  end

  describe "White space removal" do
    it "should remove white spaces from name" do
      Factory(:facility, :name => "abc    ", :code => "def").name.should eq("abc")
    end
    it "should remove white spaces from code" do
      Factory(:facility, :name => "abc ", :code => "  def   ").code.should eq("def")
    end
  end

  describe "Getting the location as a set of points" do
    it "should return an empty array if no location" do
      f = Factory(:facility, :a_lat => nil, :a_long => nil, :b_lat => nil, :b_long => nil)
      f.location_as_points.should eq([])
    end

    it "should return a single point if only 1 lat/long set" do
      f = Factory(:facility, :a_lat => 54.34, :a_long => 123.333, :b_lat => nil, :b_long => nil)
      f.location_as_points.should eq([{:lat => 54.34, :long => 123.333}])
    end

    it "should return a single point if both lat/long values are set" do
      f = Factory(:facility, :a_lat => 54.34, :a_long => 123.333, :b_lat => -34, :b_long => -178.333)
      f.location_as_points.should eq([{:lat => 54.34, :long => 123.333}, {:lat => -34, :long => -178.333}])
    end
  end

  describe "Getting all the experiments under a facility other than a known experiment" do
    before(:each) do
      @facility = Factory(:facility)
      @exp1 = Factory(:experiment, :facility => @facility, :name => "Dog")
      @exp2 = Factory(:experiment, :facility => @facility, :name => "Fish")
      @exp3 = Factory(:experiment, :facility => @facility, :name => "Cat")
    end

    it "Should return all persisted experiments if the one passed in is not yet persisted" do
      experiment = @facility.experiments.build
      @facility.experiments_excluding_me(experiment).pluck(:id).should eq([@exp3.id, @exp1.id, @exp2.id])
    end

    it "Should exclude the one passed in if it is persisted" do
      @facility.experiments_excluding_me(@exp2).pluck(:id).should eq([@exp3.id, @exp1.id])
    end
  end

end
