require 'spec_helper'

describe MetadataWriter do

  # set up fully populated example entities
  before(:each) do
    @config = SystemConfiguration.instance
    @config.update_attributes({
                      name: 'HIEv',
                      research_centre_name: 'Hawkesbury Institute for the Environment',
                      entity: 'University of Western Sydney',
                      address1: 'Locked Bag 1797',
                      address2: 'Penrith NSW, 2751',
                      address3: 'AUSTRALIA',
                      telephone_number: '+61 2 4570 1125',
                      email: 'hieinfo@lists.uws.edu.au',
                      description: 'HIE to supply this text.',
                      urls: 'http://www.uws.edu.au/hie http://www.uws.edu.au',
                      level1: 'Facility',
                      level1_plural: 'Facilities',
                      level2: 'Experiment',
                      level2_plural: 'Experiments'
    })

    @primary_contact = Factory(:user, first_name: 'Prim', last_name: 'Contact', email: 'prim@intersect.org.au')
    @facility = Factory(:facility,
                        name: 'Whole Tree Chambers',
                        id: 1,
                        code: 'WTC',
                        description: 'The Whole Tree Chambers (WTC) facility was installed',
                        a_lat: 20, a_long: 30,
                        primary_contact: @primary_contact)
    @experiment = Factory(:experiment,
                          id: 1,
                          name: 'High CO2 and Drought',
                          facility: @facility,
                          start_date: '2011-12-25',
                          end_date: '2012-01-01',
                          subject: 'Drought',
                          description: 'Experiment desc',
                          access_rights: 'http://creativecommons.org/licenses/by/3.0/au')
    @experiment.set_for_codes({'1' => {'name' => '0101 - Mathematics', 'url' => 'someurl'}, '2' => {'name' => '0202 - Science', 'url' => 'someotherurl'}})
    @experiment.save!

    cat1 = Factory(:parameter_category, name: 'Cat1')
    cat2 = Factory(:parameter_category, name: 'Cat2')
    subcat1 = Factory(:parameter_sub_category, name: 'Subcat1', parameter_category: cat1)
    subcat2 = Factory(:parameter_sub_category, name: 'Subcat2', parameter_category: cat2)
    mod1 = Factory(:parameter_modification, name: 'Excluded')
    mod2 = Factory(:parameter_modification, name: 'Added')
    mg = Factory(:parameter_unit, name: 'mg')
    @experiment.experiment_parameters.create!(parameter_category: cat1, parameter_sub_category: subcat1, parameter_modification: mod1)
    @experiment.experiment_parameters.create!(parameter_category: cat2, parameter_sub_category: subcat2, parameter_modification: mod2, parameter_unit: mg, amount: 10, comments: 'my comment')

    # TOA5 file with full metadata
    @created_by =  Factory(:user, :first_name => 'Fred', :last_name => 'Bloggs', :email => 'fred_bloggs@intersect.org.au')
    @created_by.save!
    @data_file1 = Factory(:data_file,
                          id: 1,
                          filename: "datafile.jpg",
                          experiment_id: @experiment.id,
                          file_processing_status: DataFile::STATUS_RAW,
                          format: FileTypeDeterminer::TOA5,
                          created_at: "2012-06-27 06:49:08",
                          file_processing_description: 'My file desc',
                          created_by: @created_by,
                          interval: 900,
                          start_time: '2012-10-23 07:56:45 utc',
                          end_time: '2012-12-01 22:04:23 utc')
    photo = Tag.create!(name: 'Photo')
    video = Tag.create!(name: 'Video')
    @data_file1.tag_ids = [photo.id, video.id]
    @data_file1.labels << Label.create!(name: "Label 1")
    @data_file1.save!

    Factory(:column_detail, :name => "Rnfll", :unit => 'Deg C', :data_type => 'Avg', :position => 1, :data_file => @data_file1)
    Factory(:column_detail, :name => "SoilTemp", :unit => 'M/S', :data_type => 'Max', :position => 3, :data_file => @data_file1)
    Factory(:column_detail, :name => "Humi", :unit => 'M', :data_type => 'Avg', :position => 2, :data_file => @data_file1)

    Factory(:column_mapping, :name => "Rainfall", :code => "Rnfll")

    Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "WTC", :data_file => @data_file1)
    Factory(:metadata_item, :key => MetadataKeys::TABLE_NAME_KEY, :value => "15_min", :data_file => @data_file1)
    Factory(:metadata_item, :key => 'something', :value => "Some value", :data_file => @data_file1)

    # Minimal metadata
    @data_file2 = FactoryGirl.create(:data_file,
                          filename: 'myfile.txt',
                          id: 2,
                          experiment_id: @experiment.id,
                          file_processing_status: 'PROCESSED',
                          format: nil,
                          created_at: "2012-12-27 14:09:24",
                          file_processing_description: nil,
                          created_by: @created_by)
    @data_file2.labels << Label.create!(name: "Label 2")
    @data_file2.labels << Label.create!(name: "Label 3")
    # Package file
    @pkg_creator =  Factory(:user, first_name: 'Bobby', last_name: 'Tops', email: 'bobby@intersect.org.au')
    @pkg_creator.save!
    @package = FactoryGirl.create(:package,
                          filename: 'mypackage.zip',
                          id: 3,
                          title: "Test Package Title",
                          experiment_id: @experiment.id,
                          file_processing_status: 'PACKAGE',
                          format: "BAGIT",
                          created_at: "2012-12-27 14:09:24",
                          file_processing_description: "This package contains a lot of cats. Be warned.",
                          created_by: @pkg_creator)
    @package.labels << Label.create!(name: "Package Label 1")
    @package.labels << Label.create!(name: "Package Label 2")

  end


  describe 'Basic metadata generation' do
    it 'should produce HTML with file, facility and experiment metadata (without duplication of facilities and experiments)' do
      output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2], @package)
      diff_html(output_html, 'spec/samples/readme.html')
    end

    it 'should handle a variety of experiments and facilities' do
      pending
    end
  end

  describe 'Handling cases with incomplete data (only minimal fields filled in)' do
    context 'Facilities' do
      it 'should handle missing primary contact' do
        @facility.aggregated_contactables.each { |contactable| contactable.delete }
        @facility.reload
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2], @package)
        diff_html(output_html, 'spec/samples/readme_no_facility_contact.html')
      end

      it 'should handle missing non-mandatory values' do
        @facility.a_lat = nil
        @facility.a_long = nil
        @facility.b_lat = nil
        @facility.b_long = nil
        @facility.description = nil
        @facility.save!
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2], @package)
        diff_html(output_html, 'spec/samples/readme_minimal_facility.html')
      end
    end

    context 'Experiments' do
      it 'should handle missing non-mandatory values on experiments' do
        @experiment.description = nil
        @experiment.end_date = nil
        @experiment.experiment_for_codes.delete_all
        @experiment.save!

        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2], @package)
        diff_html(output_html, 'spec/samples/readme_minimal_experiment.html')
      end

      it 'should handle experiment with no parameters' do
        @experiment.experiment_parameters.delete_all
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2], @package)
        diff_html(output_html, 'spec/samples/readme_no_experiment_parameters.html')
      end
    end
    context 'Files' do
      it 'should handle non TOA5 files that have start/end times' do
        @data_file2.start_time = '2012-10-23 07:56:45 utc'
        @data_file2.end_time = '2012-12-01 22:04:23 utc'
        @data_file2.format = nil
        @data_file2.save!
        output_html = MetadataWriter.generate_metadata_for([@data_file1, @data_file2], @package)
        diff_html(output_html, 'spec/samples/readme_non_toa5_with_start_end.html')
      end

    end
  end
end


def diff_html(output_html, expected_file)
  expected_html = File.read(File.join(Rails.root, expected_file))

  # parse the html as XML and convert to a hash for comparison, so we don't have to worry about spacing/line ending differences
  actual_hash = Hash.from_xml(output_html)
  expected_hash = Hash.from_xml(expected_html)

  clean_hash actual_hash
  clean_hash expected_hash
  diff = expected_hash.diff(actual_hash)
  unless diff == {}
    puts "HTML did not match"
    puts "Expected:"
    puts expected_html
    puts "Actual:"
    puts output_html
  end

  diff.should == {}
end

def clean_hash(hash)
  hash.each do |k, v|
    if v.kind_of? Hash
      clean_hash(v)
    else
      unless v.blank?
        hash[k] = v.to_s.gsub( /(?<!\n)\n(?!\n)/, '').gsub(/\s+/, '').strip
      end
    end
  end
end

