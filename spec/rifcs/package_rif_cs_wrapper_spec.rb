require 'spec_helper'

describe PackageRifCsWrapper do

  describe "Static values" do
    it "should always return uws as the group" do
      PackageRifCsWrapper.new(nil, [], {}).group.should eq("University of Western Sydney")
    end

    it "should always return dataset as the collection type" do
      PackageRifCsWrapper.new(nil, [], {}).collection_type.should eq("dataset")
    end
  end

  describe "Originating source" do
    it "Should return the root url as provided to the wrapper" do
      PackageRifCsWrapper.new(nil, [], {:root_url => 'http://example.com'}).originating_source.should eq('http://example.com')
    end
  end

  describe "Key" do
    it "Should return the collection url as provided to the wrapper" do
      PackageRifCsWrapper.new(nil, [], {:collection_url => 'http://example.com/1'}).key.should eq('http://example.com/1')
    end
  end

  describe "Electronic location" do
    it "Should return the collection zip url as provided to the wrapper" do
      PackageRifCsWrapper.new(nil, [], {:zip_url => 'http://example.com/1.zip'}).electronic_location.should eq('http://example.com/1.zip')
    end
  end

  describe "Notes" do

    it "should include submitter in notes" do
      user = Factory(:user, :first_name => "postman", :last_name => "pac", :email => "postmanpac@intersect.org.au")
      post_facility = Factory(:facility, :name =>'PFac', :primary_contact => user)
      experiment = Factory(:experiment, :facility => post_facility)
      package = Factory(:package, filename: 'notepackage.zip', experiment_id: experiment.id, file_processing_status: 'PACKAGE', format: "BAGIT", created_at: "2012-12-27 14:09:24",
                          file_processing_description: "This package contains a lot of cats. Be warned.", created_by: user)
      wrapper = PackageRifCsWrapper.new(package, [], {:submitter => Factory(:user, :email => "georgina@intersect.org.au", :first_name => "Georgina", :last_name => "Edwards")})
      wrapper.notes[0].should eq('Published by Georgina Edwards (georgina@intersect.org.au)')
    end

    it "should include facility contacts in notes" do
      user1 = Factory(:user, :first_name => 'Fred', :last_name => 'Smith', :email => 'fred@intersect.org.au')
      user2 = Factory(:user, :first_name => 'Bob', :last_name => 'Jones', :email => 'bob@intersect.org.au')
      facility1 = Factory(:facility, :name => 'Fac1', :primary_contact => user1)
      facility2 = Factory(:facility, :name => 'Fac2', :primary_contact => user2)
      experiment1 = Factory(:experiment, :facility => facility1)
      experiment2 = Factory(:experiment, :facility => facility1)
      experiment3 = Factory(:experiment, :facility => facility2)

      df1 = Factory(:data_file, :experiment_id => experiment1.id)
      df2 = Factory(:data_file, :experiment_id => experiment2.id)
      df3 = Factory(:data_file, :experiment_id => experiment3.id)
      df4 = Factory(:data_file, :experiment_id => experiment3.id)

      package = Factory(:package, filename: 'notepackage.zip', experiment_id: experiment1.id, file_processing_status: 'PACKAGE', format: "BAGIT", created_at: "2012-12-27 14:09:24",
                    file_processing_description: "This package contains a lot of cats. Be warned.", created_by: user1)
      wrapper = PackageRifCsWrapper.new(package, [df1, df2, df3, df4], {:submitter => Factory(:user, :email => "georgina@intersect.org.au", :first_name => "Georgina", :last_name => "Edwards")})
      wrapper.notes.size.should eq(3)
      wrapper.notes.include?('Primary contact for Fac1 is Fred Smith (fred@intersect.org.au')
      wrapper.notes.include?('Primary contact for Fac2 is Bob Jones (bob@intersect.org.au')
    end

    it "should handle facility with missing contact" do
      user = Factory(:user, :first_name => 'Fred', :last_name => 'Smith', :email => 'fred@intersect.org.au')
      facility = Factory(:facility, :name => 'Fac1', :primary_contact => user)
      facility.aggregated_contactables.each { |contactable| contactable.delete }
      facility.reload
      experiment = Factory(:experiment, :facility => facility)

      df1 = Factory(:data_file, :experiment_id => experiment.id)
      package = Factory(:package, filename: 'notepackage.zip', experiment_id: experiment.id, file_processing_status: 'PACKAGE', format: "BAGIT", created_at: "2012-12-27 14:09:24",
                    file_processing_description: "This package contains a lot of cats. Be warned.", created_by: user)

      wrapper = PackageRifCsWrapper.new(package, [df1], {:submitter => Factory(:user, :email => "georgina@intersect.org.au", :first_name => "Georgina", :last_name => "Edwards")})
      # this should never happen, its ok that nothing shows
      wrapper.notes.size.should eq(1)
    end
  end

  describe "Local subjects" do
    it "should collect all subjects from experiments associated with the files" do
      exp1 = Factory(:experiment, :subject => "Fred")
      exp2 = Factory(:experiment, :subject => "Fred")
      exp3 = Factory(:experiment, :subject => "Bob")
      exp4 = Factory(:experiment, :subject => "Jane")

      df1 = Factory(:data_file, :experiment_id => exp1.id)
      df2 = Factory(:data_file, :experiment_id => exp2.id)
      df3 = Factory(:data_file, :experiment_id => exp1.id)
      df4 = Factory(:data_file, :experiment_id => exp3.id)
      df5 = Factory(:data_file, :experiment_id => exp4.id)

      wrapper = PackageRifCsWrapper.new(nil, [df1, df2, df3, df4], {})
      wrapper.local_subjects.should eq(["Bob", "Fred"])
    end
  end

  describe "Rights" do
    it "should collect all rights from experiments associated with the files" do
      exp1 = Factory(:experiment, :access_rights => "Fred")
      exp2 = Factory(:experiment, :access_rights => "Fred")
      exp3 = Factory(:experiment, :access_rights => "Bob")
      exp4 = Factory(:experiment, :access_rights => "Jane")

      df1 = Factory(:data_file, :experiment_id => exp1.id)
      df2 = Factory(:data_file, :experiment_id => exp2.id)
      df3 = Factory(:data_file, :experiment_id => exp1.id)
      df4 = Factory(:data_file, :experiment_id => exp3.id)
      df5 = Factory(:data_file, :experiment_id => exp4.id)

      wrapper = PackageRifCsWrapper.new(nil, [df1, df2, df3, df4], {})
      wrapper.access_rights.should eq(["Bob", "Fred"])
    end
  end

  describe "Field of research codes" do
    it "should collect all FOR codes from experiments associated with the files, and strip off all but the last part of the url" do
      exp1 = Factory(:experiment)
      exp2 = Factory(:experiment)
      exp3 = Factory(:experiment)
      exp4 = Factory(:experiment)
      Factory(:experiment_for_code, :url => 'http://purl.org/asc/1297.0/2008/for/02', :experiment => exp1)
      Factory(:experiment_for_code, :url => 'http://purl.org/asc/1297.0/2008/for/0101', :experiment => exp2)
      Factory(:experiment_for_code, :url => 'http://purl.org/asc/1297.0/2008/for/0234', :experiment => exp3)
      Factory(:experiment_for_code, :url => 'http://purl.org/asc/1297.0/2008/for/05', :experiment => exp3)
      Factory(:experiment_for_code, :url => 'asdf', :experiment => exp3)
      Factory(:experiment_for_code, :url => 'http://purl.org/asc/1297.0/2008/for/020103', :experiment => exp4)

      df1 = Factory(:data_file, :experiment_id => exp1.id)
      df2 = Factory(:data_file, :experiment_id => exp2.id)
      df3 = Factory(:data_file, :experiment_id => exp1.id)
      df4 = Factory(:data_file, :experiment_id => exp3.id)
      df5 = Factory(:data_file, :experiment_id => exp4.id)

      wrapper = PackageRifCsWrapper.new(nil, [df1, df2, df3, df4], {})
      wrapper.for_codes.should eq(%w(asdf 0101 02 0234 05))
    end
  end

  describe "Locations" do
    it "should gather all locations from facilities associated with the files" do
      df1 = mock(:data_file)
      df2 = mock(:data_file)
      df3 = mock(:data_file)
      df4 = mock(:data_file)

      f1 = mock(:facility)
      f1.stub(:location_as_points).and_return([])
      f2 = mock(:facility)
      f2.stub(:location_as_points).and_return(['not empty'])
      f3 = mock(:facility)
      f3.stub(:location_as_points).and_return(['also not empty'])

      df1.stub_chain(:experiment, :facility).and_return(f1)
      df2.stub_chain(:experiment, :facility).and_return(f2)
      df3.stub_chain(:experiment, :facility).and_return(f3)
      df4.stub_chain(:experiment, :facility).and_return(f3)

      wrapper = PackageRifCsWrapper.new(nil, [df1, df2, df3, df4], {})
      wrapper.locations.should eq([['not empty'], ['also not empty']])
    end
  end

  describe "Dates" do
    let(:df1) { Factory(:data_file, :start_time => '2011-01-01 11:00 UTC', :end_time => '2011-03-01 06:00 UTC') }
    let(:df2) { Factory(:data_file, :start_time => '2011-02-01 22:00 UTC', :end_time => '2011-04-26 14:00 UTC') }
    let(:df3) { Factory(:data_file, :start_time => '2011-01-01 01:00 UTC', :end_time => '2011-01-02 18:00 UTC') }
    let(:df4) { Factory(:data_file, :start_time => '2011-03-15 06:00 UTC', :end_time => '2011-03-30 22:00 UTC') }
    let(:df5) { Factory(:data_file, :start_time => nil, :end_time => nil) }
    it "should return the earliest start date and latest end date in the matching files" do
      wrapper = PackageRifCsWrapper.new(nil, [df1, df2, df3, df4, df5], {})
      wrapper.start_date.should eq(Date.parse('2011-01-01'))
      wrapper.end_date.should eq(Date.parse('2011-04-26'))
    end

    it "should return nil if none of the files have dates" do
      wrapper = PackageRifCsWrapper.new(nil, [df5], {})
      wrapper.start_date.should be_nil
      wrapper.end_date.should be_nil
    end
  end
end
