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

  describe "Electronic location" do
    it "Should return the collection zip url as provided to the wrapper" do
      PublishedCollectionRifCsWrapper.new(nil, nil, {:zip_url => 'http://example.com/1.zip'}).electronic_location.should eq('http://example.com/1.zip')
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

  describe "Rights" do
    it "should collect all rights from experiments associated with the files" do
      exp1 = Factory(:experiment, :access_rights => "Fred")
      exp2 = Factory(:experiment, :access_rights => "Fred")
      exp3 = Factory(:experiment, :access_rights => "Bob")
      exp4 = Factory(:experiment, :access_rights => "Jane")

      df1 = Factory(:data_file, :experiment => exp1)
      df2 = Factory(:data_file, :experiment => exp2)
      df3 = Factory(:data_file, :experiment => exp1)
      df4 = Factory(:data_file, :experiment => exp3)
      df5 = Factory(:data_file, :experiment => exp4)

      wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4], {})
      wrapper.access_rights.should eq(["Bob", "Fred"])
    end
  end

  describe "Field of research codes" do
     it "should collect all FOR codes from experiments associated with the files" do
       exp1 = Factory(:experiment)
       exp2 = Factory(:experiment)
       exp3 = Factory(:experiment)
       exp4 = Factory(:experiment)
       Factory(:experiment_for_code, :url => 'http://a', :experiment => exp1)
       Factory(:experiment_for_code, :url => 'http://b', :experiment => exp2)
       Factory(:experiment_for_code, :url => 'http://b', :experiment => exp3)
       Factory(:experiment_for_code, :url => 'http://c', :experiment => exp3)
       Factory(:experiment_for_code, :url => 'http://d', :experiment => exp3)
       Factory(:experiment_for_code, :url => 'http://e', :experiment => exp4)

       df1 = Factory(:data_file, :experiment => exp1)
       df2 = Factory(:data_file, :experiment => exp2)
       df3 = Factory(:data_file, :experiment => exp1)
       df4 = Factory(:data_file, :experiment => exp3)
       df5 = Factory(:data_file, :experiment => exp4)

       wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4], {})
       wrapper.for_codes.should eq(['http://a', 'http://b', 'http://c', 'http://d'])
     end
   end

  describe "Locations" do
    it "should gather all locations from facilities associated with the files" do
      df1 = mock(:data_file)
      df2 = mock(:data_file)
      df3 = mock(:data_file)
      df4 = mock(:data_file)

      f1 = mock(:facility)
      f1.stub(:location).and_return([])
      f2 = mock(:facility)
      f2.stub(:location).and_return(['not empty'])
      f3 = mock(:facility)
      f3.stub(:location).and_return(['also not empty'])

      df1.stub_chain(:experiment, :facility).and_return(f1)
      df2.stub_chain(:experiment, :facility).and_return(f2)
      df3.stub_chain(:experiment, :facility).and_return(f3)
      df4.stub_chain(:experiment, :facility).and_return(f3)

      wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4], {})
      wrapper.locations.should eq([['not empty'], ['also not empty']])
    end
  end

  describe "Dates" do
    let(:df1) { Factory(:data_file, :start_time => '2011-01-01 11:00 UTC', :end_time => '2011-03-01 06:00 UTC') }
    let(:df2) { Factory(:data_file, :start_time => '2011-02-01 22:00 UTC', :end_time => '2011-04-26 14:00 UTC') }
    let(:df3) { Factory(:data_file, :start_time => '2011-01-01 01:00 UTC', :end_time => '2011-01-02 18:00 UTC') }
    let(:df4) { Factory(:data_file, :start_time => '2011-03-15 06:00 UTC', :end_time => '2011-03-30 22:00 UTC') }
    let(:df5) { Factory(:data_file, :start_time => nil, :end_time => nil) }
    describe "Where search criteria did not include dates" do
      it "should return the earliest start date and latest end date in the matching files" do
        wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4, df5], {})
        wrapper.start_date.should eq(Date.parse('2011-01-01'))
        wrapper.end_date.should eq(Date.parse('2011-04-26'))
      end
    end

    describe "Where search criteria did not include dates and none of the files have dates" do
      it "should return the earliest start date and latest end date in the matching files" do
        wrapper = PublishedCollectionRifCsWrapper.new(nil, [df5], {})
        wrapper.start_date.should be_nil
        wrapper.end_date.should be_nil
      end
    end

    describe "Where search criteria included start date only" do
      it "should return specified start date if some files start earlier than it" do
        wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4, df5], {:date_range => DateRange.new("2011-01-25", nil)})
        wrapper.start_date.should eq(Date.parse('2011-01-25'))
        wrapper.end_date.should eq(Date.parse('2011-04-26'))
      end
      it "should return start of earliest file if specified start date is earlier than first file" do
        wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4, df5], {:date_range => DateRange.new("2010-12-25", nil)})
        wrapper.start_date.should eq(Date.parse('2011-01-01'))
        wrapper.end_date.should eq(Date.parse('2011-04-26'))
      end
    end

    describe "Where search criteria included end date only" do
      it "should return specified end date if some files end after it" do
        wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4, df5], {:date_range => DateRange.new(nil, "2011-03-25")})
        wrapper.start_date.should eq(Date.parse('2011-01-01'))
        wrapper.end_date.should eq(Date.parse('2011-03-25'))
      end
      it "should return end of last file if specified end date is later than last file" do
        wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4, df5], {:date_range => DateRange.new(nil, "2011-05-25", nil)})
        wrapper.start_date.should eq(Date.parse('2011-01-01'))
        wrapper.end_date.should eq(Date.parse('2011-04-26'))
      end
    end

    describe "Where search criteria included start date and end date" do
      it "should return specified start/end date if some files have data outside the range" do
        wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4, df5], {:date_range => DateRange.new("2011-01-25", "2011-03-25")})
        wrapper.start_date.should eq(Date.parse('2011-01-25'))
        wrapper.end_date.should eq(Date.parse('2011-03-25'))
      end
      it "should return start of first file and end of last file if data fits inside the range" do
        wrapper = PublishedCollectionRifCsWrapper.new(nil, [df1, df2, df3, df4, df5], {:date_range => DateRange.new("2010-12-25", "2011-05-25", nil)})
        wrapper.start_date.should eq(Date.parse('2011-01-01'))
        wrapper.end_date.should eq(Date.parse('2011-04-26'))
      end

    end
  end
end