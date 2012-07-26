require 'spec_helper'

describe Facility do
  describe "Create valid object" do
    it "creating an object with the minimum fields should succeed" do
      Factory(:facility).should be_valid
    end
  end

  describe "Associations" do
    it { should have_many(:experiments) }
    it { should have_one(:primary_contact) }
    it { should have_many(:contacts) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it { should ensure_length_of(:description).is_at_most 8192 }
    #it { should validate_presence_of(:primary_contact) }
    it "should validate uniqueness of name" do
      Factory(:facility)
      should validate_uniqueness_of(:name)
    end
    it "should validate uniqueness of code" do
      Factory(:facility)
      should validate_uniqueness_of(:code)
    end
    it "should, validate that lat/long are a pair" do
      pending
      #f1 = Factory(:facility, :a_lat => 5)
      #f1.
    end

    it "should validate that lat/longs are numbers" do
      should validate_numericality_of(:a_lat).with_message("must be a number between -90 and 90")
      should validate_numericality_of(:b_lat).with_message("must be a number between -90 and 90")
      should validate_numericality_of(:a_long).with_message("must be a number between -180 and 180")
      should validate_numericality_of(:b_long).with_message("must be a number between -180 and 180")
    end

    it "should validate sane latitudes/longitudes" do
      should ensure_inclusion_of(:a_lat).in_range(-90..90).with_message("must be a number between -90 and 90")
      should ensure_inclusion_of(:a_long).in_range(-180..180).with_message("must be a number between -180 and 180")
      should ensure_inclusion_of(:b_lat).in_range(-90..90).with_message("must be a number between -90 and 90")
      should ensure_inclusion_of(:b_long).in_range(-180..180).with_message("must be a number between -180 and 180")
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
      @facility.experiments_excluding_me(experiment).collect(&:id).should eq([@exp3.id, @exp1.id, @exp2.id])
    end

    it "Should exclude the one passed in if it is persisted" do
      @facility.experiments_excluding_me(@exp2).collect(&:id).should eq([@exp3.id, @exp1.id])
    end
  end

  describe "Write metadata to file" do
    it "should produce a file with details written one per line" do
      primary_contact = Factory(:user, first_name: 'Prim',
                                last_name: 'Contact',
                                email: 'prim@intersect.org.au')
      facility = Factory(:facility, name: 'Whole Tree Chambers',
                         code: 'WTC',
                         description: 'The Whole Tree Chambers (WTC) facility was installed',
                         a_lat: 20, a_long: 30,
                         primary_contact: primary_contact)
      directory = Dir.mktmpdir
      file_path = facility.write_metadata_to_file(directory)
      file_path.should =~ /whole-tree-chambers.txt/
      file_path.should be_same_file_as(Rails.root.join('samples/metadata/facility.txt'))
    end
  end
end
