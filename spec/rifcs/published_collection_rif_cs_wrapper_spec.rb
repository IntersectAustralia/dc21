require 'spec_helper'

describe PublishedCollectionRifCsWrapper do

  describe "Static values" do
    it "should always return uws as the group" do
      PublishedCollectionRifCsWrapper.new(nil, nil, {}).group.should eq("University of Western Sydney")
    end

    it "should always return dataset as the collection type" do
      PublishedCollectionRifCsWrapper.new(nil, nil, {}).collection_type.should eq("dataset")

    end

  end

  describe "Originating source" do
    it "Should return the root url as provided to the wrapper" do
      PublishedCollectionRifCsWrapper.new(nil, nil, {:root_url => 'http://example.com'}).originating_source.should eq('http://example.com')
    end
  end

  describe "Key" do
    it "Should return the collection url as provided to the wrapper" do
      PublishedCollectionRifCsWrapper.new(nil, nil, {:collection_url => 'http://example.com/1'}).key.should eq('http://example.com/1')
    end
  end

  describe "Local subjects" do
    it "should collect all subjects from experiments associated with the files" do
      exp1 = Factory(:experiment, :subject => "Fred")
      exp2 = Factory(:experiment, :subject => "Fred")
      exp3 = Factory(:experiment, :subject => "Bob")
      exp4 = Factory(:experiment, :subject => "Jane")

      df1 = Factory(:data_file, :experiment => exp1)
      df2 = Factory(:data_file, :experiment => exp2)
      df3 = Factory(:data_file, :experiment => exp1)
      df4 = Factory(:data_file, :experiment => exp3)
      df5 = Factory(:data_file, :experiment => exp4)

      wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4], {})
      wrapper.local_subjects.should eq(["Bob", "Fred"])
    end
  end
end