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
    it { should validate_presence_of(:primary_contact) }
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

    it "should validate sane latitudes/longitudes" do
      should ensure_inclusion_of(:a_lat).in_range -90..90
      should ensure_inclusion_of(:a_long).in_range -180..180
      should ensure_inclusion_of(:b_lat).in_range -90..90
      should ensure_inclusion_of(:b_long).in_range -180..180
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
end
