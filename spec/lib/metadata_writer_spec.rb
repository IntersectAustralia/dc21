require 'spec_helper'

describe MetadataWriter do

  before(:each) do
    @subject = MetadataWriter.new(nil, nil)
  end

  describe "Write facility metadata to file" do
    it "should produce a file with details written one per line" do
      primary_contact = Factory(:user,
                                first_name: 'Prim',
                                last_name: 'Contact',
                                email: 'prim@intersect.org.au')

      facility = Factory(:facility, 
                         name: 'Whole Tree Chambers',
                         id: 1,
                         code: 'WTC',
                         description: 'The Whole Tree Chambers (WTC) facility was installed',
                         a_lat: 20, a_long: 30,
                         primary_contact: primary_contact)

      directory = Dir.mktmpdir
      file_path = @subject.write_facility_metadata(facility, directory)
      file_path.should =~ /whole-tree-chambers.txt/
      file_path.should be_same_file_as(Rails.root.join('samples/metadata/facility.txt'))
    end
  end
  describe "write experiement metadata to file" do

    before(:each) do

      facility = Factory(:facility, id:1, name: 'My Facility')

      # Set only mandatory fields
      @experiment = Factory(:experiment,
                            id: 1,
                            name: 'High CO2 and Drought',
                            facility: facility,
                            start_date: '2011-12-25',
                            subject: 'Drought')
      @directory = Dir.mktmpdir
    end


    it "should produce a file with details written one per line" do
      @experiment.description = 'This is my description.'
      @experiment.end_date = '2012-01-01'
      file_path = @subject.write_experiment_metadata(@experiment, @directory)
      file_path.should =~ /high-co2-and-drought.txt$/
      file_path.should be_same_file_as(Rails.root.join('samples/metadata/experiment1.txt'))
    end

    it "should handle missing non-mandatory values" do
      file_path = @subject.write_experiment_metadata(@experiment, @directory)
      file_path.should be_same_file_as(Rails.root.join('samples/metadata/experiment_optional.txt'))
    end
  end

  describe "write data file metadata to file" do
    it "should produce a file with details written one per line" do
      experiment = Factory(:experiment)
      data_file = Factory(:data_file,
                           id: 1,
                           filename: "datafile",
                           experiment: experiment,
                           format: FileTypeDeterminer::TOA5,
                           created_at: "2012-06-27 06:49:08")
      Factory(:column_detail, :name => "Rnfll", :data_file => data_file)
      Factory(:column_detail, :name => "SoilTemp", :data_file => data_file)
      Factory(:column_detail, :name => "Humi", :data_file => data_file)


      Factory(:column_mapping, :name => "Rainfall", :code => "Rnfll")
      Factory(:column_mapping, :name => "Soil Temperature", :code => "SoilTemp")
      Factory(:column_mapping, :name => "Humidity", :code => "Humi")

      directory = Dir.mktmpdir
      file_path = @subject.write_data_file_metadata(data_file, directory)
      file_path.should =~ /datafile-metadata.txt$/
      file_path.should be_same_file_as(Rails.root.join('samples/metadata/datafile-metadata.txt'))
    end
  end
end
