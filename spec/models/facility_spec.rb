require 'spec_helper'

describe Facility do
  describe "Create valid object" do
    it "creating an object with the minimum fields should succeed" do
      Factory(:facility).should be_valid
    end
  end

  describe "Associations" do
    it { should have_many(:experiments) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:code) }
    it "should validate uniqueness of name" do
      Factory(:facility)
      should validate_uniqueness_of(:name)
    end
    it "should validate uniqueness of code" do
      Factory(:facility)
      should validate_uniqueness_of(:code)
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
