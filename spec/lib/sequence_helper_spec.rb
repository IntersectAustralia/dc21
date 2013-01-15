require 'spec_helper'

describe SequenceHelper do

  describe "Empty list of used numbers" do
    it "should return 1" do
      SequenceHelper.next_available([]).should eq(1)
    end
  end

  describe "Continuous numbers" do
    it "should return the next available" do
      SequenceHelper.next_available([1, 2, 3, 4, 5, 6, 7]).should eq(8)
    end

    it "should return 1 if sequence starts higher than 1" do
      SequenceHelper.next_available([2, 3, 4, 5, 6, 7]).should eq(1)
    end
  end

  describe "With gaps" do
    it "should return first available gap" do
      SequenceHelper.next_available([1, 3]).should eq(2)
      SequenceHelper.next_available([1, 2, 3, 4, 45, 232, 1222]).should eq(5)
    end
  end
end
