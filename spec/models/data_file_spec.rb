require 'spec_helper'
require 'cancan/matchers'

describe DataFile do

  let(:file) do
    Factory(:data_file, :path => 'some_path', :filename => 'agg.ncml', :format => FileTypeDeterminer::NCML)
  end

  describe "#is_ncml?" do

    context "when file is ncml format" do
      it { file.is_ncml?.should be_true }
    end

    context "when file is not ncml format" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'agg.xml', :format => FileTypeDeterminer::NETCDF)
      end
      it { file.is_ncml?.should be_false }
      it { file.is_netcdf?.should be_true }
    end
  end

  describe "#show_columns" do
    context "when file is toa5" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.dat', :format => FileTypeDeterminer::TOA5)
      end
      it { file.show_columns?.should be_true}
    end

    context "when file is netcdf" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.nc', :format => FileTypeDeterminer::NETCDF)
      end
      it { file.show_columns?.should be_true}
    end

    context "when file is ncml" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.ncml', :format => FileTypeDeterminer::NCML)
      end
      it { file.show_columns?.should be_true}
    end

    context "when file is text" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.txt', :format => "text/plain")
      end
      it { file.show_columns?.should be_false}
    end
  end

  describe "#show_information_from_file" do
    context "when file is toa5" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.dat', :format => FileTypeDeterminer::TOA5)
      end
      it { file.show_information_from_file?.should be_true}
    end

    context "when file is netcdf" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.nc', :format => FileTypeDeterminer::NETCDF)
      end
      it { file.show_information_from_file?.should be_true}
    end

    context "when file is ncml" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.ncml', :format => FileTypeDeterminer::NCML)
      end
      it { file.show_information_from_file?.should be_true}
    end

    context "when file is exif image" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.xtiff', :format => "image/x-tiff")
      end
      it { file.show_information_from_file?.should be_true}
    end

    context "when file is text" do
      let(:file) do
        Factory(:data_file, :path => 'some_path', :filename => 'file.txt', :format => "text/plain")
      end
      it { file.show_information_from_file?.should be_false}
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:filename) }
    it { should validate_presence_of(:path) }
    it { should validate_presence_of(:created_by_id) }
    it { should validate_presence_of(:file_processing_status) }
    it { should validate_presence_of(:experiment) }


    it "should validate uniqueness of filename" do
      Factory(:data_file)
      should validate_uniqueness_of(:filename)
    end

    context "should validate presence of access rights type for packages only" do
      it { should_not validate_presence_of(:access_rights_type) }

      let(:package) do
        Factory(:data_file, format: FileTypeDeterminer::BAGIT, access_rights_type: 'Open', license: 'http://creativecommons.org/licenses/by/4.0')
      end
      it { package.should validate_inclusion_of(:access_rights_type).in_array(DataFile::ACCESS_RIGHTS_TYPES)}
    end


    context "should validate presence of licence in packages only" do
      it { should_not validate_presence_of(:access_rights_type) }

      let(:package) do
        Factory(:data_file, format: FileTypeDeterminer::BAGIT, access_rights_type: 'Open', license: 'http://creativecommons.org/licenses/by/4.0')
      end
      it { package.should validate_inclusion_of(:license).in_array(AccessRightsLookup.new.access_rights_values) }
    end

    it 'ensures a start time, but only if end_time specified' do
      now = DateTime.now
      file = Factory(:data_file)
      file.end_time = now
      file.should_not be_valid

      file.start_time = now
      file.should be_valid
    end
    it 'ensures end time is >= start time' do
      now = DateTime.now
      file = Factory(:data_file)

      file.start_time = now
      file.end_time = now -1

      file.should_not be_valid
    end

    it 'ensures access to all institutional users option is not set if access is public' do
      file = Factory(:data_file)
      file.access = DataFile::ACCESS_PUBLIC
      file.access_to_all_institutional_users = true
      file.should_not be_valid
    end

    it 'ensures access to group users options is not set if access is public' do
      file = Factory(:data_file)
      file.access = DataFile::ACCESS_PUBLIC
      file.access_to_user_groups = true
      file.should_not be_valid
    end

    it 'invalid url should fail validation' do
      file = Factory(:data_file)
      file.related_website_list = "www"
      file.should_not be_valid
    end

    it 'valid url' do
      file = Factory(:data_file)
      file.related_website_list = "http://www.example.com"
      file.should be_valid
    end

    describe "Abilities" do
      before(:each) do
        @super_role = Factory(:role, :name => "Administrator")
        @inst_role = Factory(:role, :name => "Institutional User")
        @non_inst_role = Factory(:role, :name => "Non-Institutional User")

        @admin_user = Factory(:user, :role => @super_role, :status => "A")
        @inst_user = Factory(:user, :role => @inst_role, :status => "A")
        @non_inst_user = Factory(:user, :role => @non_inst_role, :status => "A")

        @public_file = Factory(:data_file, :access => DataFile::ACCESS_PUBLIC, :access_to_all_institutional_users => false, :access_to_user_groups => false, :created_by => @admin_user)
        @private_file_all_inst = Factory(:data_file, :access => DataFile::ACCESS_PRIVATE, :access_to_all_institutional_users => true, :created_by => @inst_user)
        @restricted_file_no_groups = Factory(:data_file, :access => DataFile::ACCESS_PRIVATE, :access_to_all_institutional_users => false, :created_by => @non_inst_user, :access_to_user_groups => true)

        @group_a = Factory(:access_group, :primary_user => @admin_user, :users => [@inst_user])
        @restricted_file_group_a = Factory(:data_file, :access => DataFile::ACCESS_PRIVATE, :access_to_all_institutional_users => false, :access_to_user_groups => true, :access_groups => [@group_a])
        @group_b = Factory(:access_group, :primary_user => @admin_user, :users => [@non_inst_user])
        @restricted_file_group_b = Factory(:data_file, :access => DataFile::ACCESS_PRIVATE, :access_to_all_institutional_users => false, :access_to_user_groups => true, :access_groups => [@group_b])
      end

      describe "as Institutional User" do
        before(:each) do
          @ability = Ability.new(@inst_user)
        end

        it "can access public data files" do
          @ability.should be_able_to(:index, @public_file)
          @ability.should be_able_to(:show, @public_file)
          @ability.should be_able_to(:create, @public_file)
          @ability.should be_able_to(:download, @public_file)
          @ability.should be_able_to(:download_selected, @public_file)
          @ability.should be_able_to(:bulk_update, @public_file)
          @ability.should be_able_to(:api_create, @public_file)
          @ability.should be_able_to(:api_search, @public_file)
          @ability.should be_able_to(:process_metadata_extraction, @public_file)
          @ability.should be_able_to(:search, @public_file)
        end

        it "can access private data files open to all institutional users" do
          @ability.should be_able_to(:index, @private_file_all_inst)
          @ability.should be_able_to(:show, @private_file_all_inst)
          @ability.should be_able_to(:create, @private_file_all_inst)
          @ability.should be_able_to(:download, @private_file_all_inst)
          @ability.should be_able_to(:download_selected, @private_file_all_inst)
          @ability.should be_able_to(:bulk_update, @private_file_all_inst)
          @ability.should be_able_to(:api_create, @private_file_all_inst)
          @ability.should be_able_to(:api_search, @private_file_all_inst)
          @ability.should be_able_to(:process_metadata_extraction, @private_file_all_inst)
          @ability.should be_able_to(:search, @private_file_all_inst)
        end

        it "can access private data files associated with an access group that they belong to" do
          @ability.should be_able_to(:index, @restricted_file_group_a)
          @ability.should be_able_to(:show, @restricted_file_group_a)
          @ability.should be_able_to(:create, @restricted_file_group_a)
          @ability.should be_able_to(:download, @restricted_file_group_a)
          @ability.should be_able_to(:download_selected, @restricted_file_group_a)
          @ability.should be_able_to(:bulk_update, @restricted_file_group_a)
          @ability.should be_able_to(:api_create, @restricted_file_group_a)
          @ability.should be_able_to(:api_search, @restricted_file_group_a)
          @ability.should be_able_to(:process_metadata_extraction, @restricted_file_group_a)
          @ability.should be_able_to(:search, @restricted_file_group_a)
        end

        it "cannot access private data files of restricted access that they do not belong to the access groups" do
          @restricted_file_no_groups = Factory(:data_file, :access => DataFile::ACCESS_PRIVATE, :access_to_all_institutional_users => false, :created_by => @non_inst_user, :access_to_user_groups => true)

          @ability.should be_able_to(:index, @restricted_file_no_groups)
          @ability.should be_able_to(:create, @restricted_file_no_groups)
          @ability.should be_able_to(:api_create, @restricted_file_no_groups)
          @ability.should be_able_to(:search, @restricted_file_no_groups)

          @ability.should_not be_able_to(:show, @restricted_file_no_groups)
          @ability.should_not be_able_to(:download, @restricted_file_no_groups)
          @ability.should_not be_able_to(:download_selected, @restricted_file_no_groups)
          @ability.should_not be_able_to(:bulk_update, @restricted_file_no_groups)
          @ability.should_not be_able_to(:api_search, @restricted_file_no_groups)
          @ability.should_not be_able_to(:process_metadata_extraction, @restricted_file_no_groups)
        end

        it "can access private restricted data files that they uploaded themselves" do
          restricted_file_uploaded_by_user = Factory(:data_file, :access => DataFile::ACCESS_PRIVATE, :access_to_all_institutional_users => false, :created_by => @inst_user, :access_to_user_groups => true)
          @ability.should be_able_to(:index, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:show, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:create, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:download, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:download_selected, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:bulk_update, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:api_create, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:api_search, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:process_metadata_extraction, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:search, restricted_file_uploaded_by_user)
        end
      end

      describe "as a Non-Institutional User" do
        before(:each) do
          @ability = Ability.new(@non_inst_user)
        end

        it "can access public data files" do
          @ability.should be_able_to(:index, @public_file)
          @ability.should be_able_to(:show, @public_file)
          @ability.should be_able_to(:create, @public_file)
          @ability.should be_able_to(:download, @public_file)
          @ability.should be_able_to(:download_selected, @public_file)
          @ability.should be_able_to(:bulk_update, @public_file)
          @ability.should be_able_to(:api_create, @public_file)
          @ability.should be_able_to(:api_search, @public_file)
          @ability.should be_able_to(:process_metadata_extraction, @public_file)
          @ability.should be_able_to(:search, @public_file)
        end

        it "cannot access private data files open to all institutional users" do
          @ability.should be_able_to(:index, @private_file_all_inst)
          @ability.should be_able_to(:create, @private_file_all_inst)
          @ability.should be_able_to(:api_create, @private_file_all_inst)
          @ability.should be_able_to(:search, @private_file_all_inst)

          @ability.should_not be_able_to(:show, @private_file_all_inst)
          @ability.should_not be_able_to(:download, @private_file_all_inst)
          @ability.should_not be_able_to(:download_selected, @private_file_all_inst)
          @ability.should_not be_able_to(:bulk_update, @private_file_all_inst)
          @ability.should_not be_able_to(:api_search, @private_file_all_inst)
          @ability.should_not be_able_to(:process_metadata_extraction, @private_file_all_inst)
        end

        it "can access private data files associated with an access group that they belong to" do
          @ability.should be_able_to(:index, @restricted_file_group_b)
          @ability.should be_able_to(:show, @restricted_file_group_b)
          @ability.should be_able_to(:create, @restricted_file_group_b)
          @ability.should be_able_to(:download, @restricted_file_group_b)
          @ability.should be_able_to(:download_selected, @restricted_file_group_b)
          @ability.should be_able_to(:bulk_update, @restricted_file_group_b)
          @ability.should be_able_to(:api_create, @restricted_file_group_b)
          @ability.should be_able_to(:api_search, @restricted_file_group_b)
          @ability.should be_able_to(:process_metadata_extraction, @restricted_file_group_b)
          @ability.should be_able_to(:search, @restricted_file_group_b)
        end

        it "cannot access private data files of restricted access that they do not belong to the access groups" do
          restricted_file = Factory(:data_file, :access => DataFile::ACCESS_PRIVATE, :access_to_all_institutional_users => false, :created_by => @inst_user, :access_to_user_groups => true)

          @ability.should be_able_to(:index, restricted_file)
          @ability.should be_able_to(:create, restricted_file)
          @ability.should be_able_to(:api_create, restricted_file)
          @ability.should be_able_to(:search, restricted_file)

          @ability.should_not be_able_to(:show, restricted_file)
          @ability.should_not be_able_to(:download, restricted_file)
          @ability.should_not be_able_to(:download_selected, restricted_file)
          @ability.should_not be_able_to(:bulk_update, restricted_file)
          @ability.should_not be_able_to(:api_search, restricted_file)
          @ability.should_not be_able_to(:process_metadata_extraction, restricted_file)
        end

        it "can access private restricted data files that they uploaded themselves" do
          restricted_file_uploaded_by_user = Factory(:data_file, :access => DataFile::ACCESS_PRIVATE, :access_to_all_institutional_users => false, :created_by => @non_inst_user, :access_to_user_groups => true)
          @ability.should be_able_to(:index, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:show, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:create, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:download, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:download_selected, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:bulk_update, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:api_create, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:api_search, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:process_metadata_extraction, restricted_file_uploaded_by_user)
          @ability.should be_able_to(:search, restricted_file_uploaded_by_user)
        end
      end


      describe "as admin" do
        it "can access all data files" do
          ability = Ability.new(@admin_user)
          ability.should be_able_to(:read, @public_file)
          ability.should be_able_to(:create, @public_file)
          ability.should be_able_to(:download, @public_file)
          ability.should be_able_to(:download_selected, @public_file)
          ability.should be_able_to(:bulk_update, @public_file)
          ability.should be_able_to(:api_create, @public_file)
          ability.should be_able_to(:api_search, @public_file)
          ability.should be_able_to(:process_metadata_extraction, @public_file)
          ability.should be_able_to(:search, @public_file)

          ability.should be_able_to(:read, @private_file_all_inst)
          ability.should be_able_to(:create, @private_file_all_inst)
          ability.should be_able_to(:download, @private_file_all_inst)
          ability.should be_able_to(:download_selected, @private_file_all_inst)
          ability.should be_able_to(:bulk_update, @private_file_all_inst)
          ability.should be_able_to(:api_create, @private_file_all_inst)
          ability.should be_able_to(:api_search, @private_file_all_inst)
          ability.should be_able_to(:process_metadata_extraction, @private_file_all_inst)
          ability.should be_able_to(:search, @private_file_all_inst)

          ability.should be_able_to(:read, @restricted_file_no_groups)
          ability.should be_able_to(:create, @restricted_file_no_groups)
          ability.should be_able_to(:download, @restricted_file_no_groups)
          ability.should be_able_to(:download_selected, @restricted_file_no_groups)
          ability.should be_able_to(:bulk_update, @restricted_file_no_groups)
          ability.should be_able_to(:api_create, @restricted_file_no_groups)
          ability.should be_able_to(:api_search, @restricted_file_no_groups)
          ability.should be_able_to(:process_metadata_extraction, @restricted_file_no_groups)
          ability.should be_able_to(:search, @restricted_file_no_groups)

          ability.should be_able_to(:read, @restricted_file_group_a)
          ability.should be_able_to(:create, @restricted_file_group_a)
          ability.should be_able_to(:download, @restricted_file_group_a)
          ability.should be_able_to(:download_selected, @restricted_file_group_a)
          ability.should be_able_to(:bulk_update, @restricted_file_group_a)
          ability.should be_able_to(:api_create, @restricted_file_group_a)
          ability.should be_able_to(:api_search, @restricted_file_group_a)
          ability.should be_able_to(:process_metadata_extraction, @restricted_file_group_a)
          ability.should be_able_to(:search, @restricted_file_group_a)

          ability.should be_able_to(:read, @restricted_file_group_b)
          ability.should be_able_to(:create, @restricted_file_group_b)
          ability.should be_able_to(:download, @restricted_file_group_b)
          ability.should be_able_to(:download_selected, @restricted_file_group_b)
          ability.should be_able_to(:bulk_update, @restricted_file_group_b)
          ability.should be_able_to(:api_create, @restricted_file_group_b)
          ability.should be_able_to(:api_search, @restricted_file_group_b)
          ability.should be_able_to(:process_metadata_extraction, @restricted_file_group_b)
          ability.should be_able_to(:search, @restricted_file_group_b)
        end
      end
    end
  end

  describe "File processing description length" do
    it "should truncate when the field is over 10 kilobytes" do
      df = Factory.create(:data_file, :file_processing_description => "x" * 20000)
      df.file_processing_description.length.should eq 10240
      Factory.build(:data_file, :file_processing_description => "x" * 10240).should be_valid
    end
  end

  describe "Callbacks" do
    it "set end date before save if blank" do
      df = Factory(:data_file, :start_time => "2011-01-01 11:00 UTC")
      df.save!
      df.end_time.should eq("2011-01-01 11:00 UTC")
    end
  end

  describe "Associations" do
    it { should belong_to(:created_by) }
    it { should have_many(:column_details) }
    it { should have_many(:metadata_items) }
    it { should have_and_belong_to_many(:users) }
    it { should have_and_belong_to_many(:tags) }
    it { should have_many(:access_groups)}
    it { should have_many(:grant_numbers) }
    it { should have_many(:related_websites) }
  end

  describe "Get experiment name" do
    it "returns the experiment name" do
      exp = Factory(:experiment, :name => "Fred")
      Factory(:data_file, :experiment_id => exp.id).experiment_name.should eq("Fred")
    end
  end

  describe "Get facility name" do
    it "returns the facility name" do
      facility = Factory(:facility, :name => "Bob")
      exp = Factory(:experiment, :name => "Fred", :facility => facility)
      Factory(:data_file, :experiment_id => exp.id).facility_name.should eq("Bob")
    end
  end

  describe "Get file extension" do
    it "should return the correct extension" do
      Factory(:data_file, :filename => "abc.csv").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.def.csv").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.txt").extension.should eq("txt")
      Factory(:data_file, :filename => "abc.txt123").extension.should eq("txt123")
      Factory(:data_file, :filename => "txt123").extension.should be_nil
    end

    it "should downcase the extension" do
      Factory(:data_file, :filename => "abc.csv").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.CSV").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.cSV").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.Csv").extension.should eq("csv")
    end
  end

  describe "File format for display" do
    it "should return 'Unknown' if no format set" do
      Factory(:data_file, :format => FileTypeDeterminer::UNKNOWN).format.should eq("Unknown")
    end

    it "should return the format if set" do
      Factory(:data_file, :format => "TOA5").format.should eq("TOA5")
    end
  end

  describe "Search scopes" do
    describe "Find files with matching filename" do
      it "should support partial and case-insensitive matches" do
        f1 = Factory(:data_file, :filename => "blah.txt").id
        f2 = Factory(:data_file, :filename => "BLAH.txt").id
        f3 = Factory(:data_file, :filename => "Blah.txt").id
        f4 = Factory(:data_file, :filename => "AblahABC.txt").id
        f5 = Factory(:data_file, :filename => "ABC.txt").id
        f6 = Factory(:data_file, :filename => "AB.bl").id

        DataFile.with_filename_containing("blAH").order(:id).pluck(:id).should eq([f1, f2, f3, f4])
        DataFile.with_filename_containing("BL").order(:id).pluck(:id).should eq([f1, f2, f3, f4, f6])
        DataFile.with_filename_containing("ABC").order(:id).pluck(:id).should eq([f4, f5])
        DataFile.with_filename_containing("DEF").should be_empty
      end
    end

    describe "Find files with experiment" do
      it "Find files with experiment" do
        ex1 = Factory(:experiment, :name => "My experiment one")
        ex2 = Factory(:experiment, :name => "My experiment two")
        f1 = Factory(:data_file, :experiment_id => ex1.id).id
        f2 = Factory(:data_file, :experiment_id => ex1.id).id
        f3 = Factory(:data_file, :experiment_id => ex1.id).id
        f4 = Factory(:data_file, :experiment_id => ex2.id).id
        f5 = Factory(:data_file, :experiment_id => ex2.id).id
        f6 = Factory(:data_file, :experiment_id => ex2.id).id

        DataFile.with_experiment([ex1.id]).order(:id).pluck(:id).should eq([f1, f2, f3])
        DataFile.with_experiment([ex2.id]).order(:id).pluck(:id).should eq([f4, f5, f6])
        DataFile.with_experiment([ex1.id, ex2.id]).order(:id).pluck(:id).should eq([f1, f2, f3, f4, f5, f6])
      end
    end

    describe "Find files with uploader" do
      it "Find files for uploader" do
        u1 = Factory(:user)
        u2 = Factory(:user)
        f1 = Factory(:data_file, :created_by_id => u1.id).id
        f2 = Factory(:data_file, :created_by_id => u1.id).id
        f3 = Factory(:data_file, :created_by_id => u1.id).id
        f4 = Factory(:data_file, :created_by_id => u2.id).id
        f5 = Factory(:data_file, :created_by_id => u2.id).id
        f6 = Factory(:data_file, :created_by_id => u2.id).id

        DataFile.with_uploader(u1.id).order(:id).pluck(:id).should eq([f1, f2, f3])
        DataFile.with_uploader(u2.id).order(:id).pluck(:id).should eq([f4, f5, f6])
      end
    end

    describe "Find files with matching description" do
      it "should support partial and case-insensitive matches" do
        f1 = Factory(:data_file, :file_processing_description => "blah").id
        f2 = Factory(:data_file, :file_processing_description => "BLAH").id
        f3 = Factory(:data_file, :file_processing_description => "Blah").id
        f4 = Factory(:data_file, :file_processing_description => "A blahABC de").id
        f5 = Factory(:data_file, :file_processing_description => "ABC").id
        f6 = Factory(:data_file, :file_processing_description => "AB.bl").id

        DataFile.with_description_containing("blAH").order(:id).pluck(:id).should eq([f1, f2, f3, f4])
        DataFile.with_description_containing("BL").order(:id).pluck(:id).should eq([f1, f2, f3, f4, f6])
        DataFile.with_description_containing("ABC").order(:id).pluck(:id).should eq([f4, f5])
        DataFile.with_description_containing("DEF").should be_empty
      end
    end

    describe "Find files with processing status in" do
      it "should find matching files" do
        f1 = Factory(:data_file, :file_processing_status => DataFile::STATUS_ERROR).id
        f2 = Factory(:data_file, :file_processing_status => 'PROCESSED').id
        f3 = Factory(:data_file, :file_processing_status => DataFile::STATUS_RAW).id
        f4 = Factory(:data_file, :file_processing_status => 'UNKNOWN').id
        f5 = Factory(:data_file, :file_processing_status => 'CLEANSED').id
        f6 = Factory(:data_file, :file_processing_status => DataFile::STATUS_RAW).id

        DataFile.with_status_in([DataFile::STATUS_RAW, 'CLEANSED']).order(:id).pluck(:id).should eq([f3, f5, f6])
        DataFile.with_status_in([DataFile::STATUS_ERROR]).order(:id).pluck(:id).should eq([f1])
      end
    end

    describe "Find files with tags" do
      it "should find matching files" do
        t1 = Factory(:tag, :name => "Photo").id
        t2 = Factory(:tag, :name => "Video").id
        t3 = Factory(:tag, :name => "Audit").id

        f1 = Factory(:data_file, :tag_ids => []).id
        f2 = Factory(:data_file, :tag_ids => [t1, t2]).id
        f3 = Factory(:data_file, :tag_ids => [t1]).id
        f4 = Factory(:data_file, :tag_ids => [t2]).id
        f5 = Factory(:data_file, :tag_ids => [t1, t2, t3]).id
        f6 = Factory(:data_file, :tag_ids => [t3]).id

        DataFile.with_any_of_these_tags([t1]).order(:id).pluck(:id).should eq([f2, f3, f5])
        DataFile.with_any_of_these_tags([t2]).order(:id).pluck(:id).should eq([f2, f4, f5])
        DataFile.with_any_of_these_tags([t1, t2]).order(:id).pluck(:id).should eq([f2, f3, f4, f5])
      end
    end

    #EYETRACKER-134
    describe "Find files with matching file formats" do
      it "should find matching files" do
        f1 = Factory(:data_file, :format => FileTypeDeterminer::UNKNOWN).id
        f2 = Factory(:data_file, :format => FileTypeDeterminer::TOA5).id
        f3 = Factory(:data_file, :format => FileTypeDeterminer::BAGIT, access_rights_type: 'Open', license: 'http://creativecommons.org/licenses/by/4.0').id
        f4 = Factory(:data_file, :format => 'image/png').id
        f5 = Factory(:data_file, :format => 'video/mpeg').id
        f6 = Factory(:data_file, :format => 'audio/mpeg').id
        f7 = Factory(:data_file, :format => 'image/jpeg').id

        DataFile.with_any_of_these_file_formats([FileTypeDeterminer::TOA5]).order(:id).pluck(:id).should eq([f2])
        DataFile.with_any_of_these_file_formats([FileTypeDeterminer::UNKNOWN, 'audio/mpeg']).order(:id).pluck(:id).should eq([f1, f6])
        DataFile.with_any_of_these_file_formats(['video/mpeg', FileTypeDeterminer::BAGIT, 'image/jpeg']).order(:id).pluck(:id).should eq([f3, f5, f7])
      end
    end
  end

  describe "Find files for date range" do
    def test_data_in_range(files, date1, date2, mapping)
      files.each do |label, file|
        DataFile.find(file).has_data_in_range?(date1, date2).should(mapping[label], "Failed on file #{label}")
      end
    end

    before(:each) do
      @files = {
          :f1 => Factory(:data_file, :start_time => "2011-01-01 11:00 UTC", :end_time => "2011-02-28 11:00 UTC", :format => "TOA5").id, # jan1 to feb28
          :f2 => Factory(:data_file, :start_time => "2011-01-01 00:00 UTC", :end_time => "2011-04-30 22:59 UTC", :format => "TOA5").id, # jan1 to apr30
          :f3 => Factory(:data_file, :start_time => "2011-02-01 11:00 UTC", :end_time => "2011-03-31 22:59 UTC", :format => "TOA5").id, # feb1 to mar31
          :f4 => Factory(:data_file, :start_time => "2011-03-01 11:00 UTC", :end_time => "2011-04-30 11:00 UTC", :format => "TOA5").id, # mar1 to apr30
          :f5 => Factory(:data_file, :start_time => "2011-01-01 11:00 UTC", :end_time => "2011-01-31 11:00 UTC", :format => "TOA5").id, # jan1 to jan31
          :f6 => Factory(:data_file, :start_time => "2011-04-01 00:00 UTC", :end_time => "2011-04-30 11:00 UTC", :format => "TOA5").id, # apr1 to apr30
          :f7 => Factory(:data_file, :start_time => "2011-04-01 00:00 UTC", :end_time => "2011-04-01 00:00 UTC", :format => "TOA5").id, # apr1 - same start / finish
          :f8 => Factory(:data_file, :start_time => nil, :end_time => nil, :format => nil)
      }

      @f1 = @files[:f1]
      @f2 = @files[:f2]
      @f3 = @files[:f3]
      @f4 = @files[:f4]
      @f5 = @files[:f5]
      @f6 = @files[:f6]
      @f7 = @files[:f7]
      @f8 = @files[:f8]
    end

    describe "has data in range method should correctly identify if data falls in range" do
      it "should work with start date only" do

        mapping = {
            :f1 => be_false, # jan1 to feb28
            :f2 => be_true, # jan1 to apr30
            :f3 => be_true, # feb1 to mar31
            :f4 => be_true, # mar1 to apr30
            :f5 => be_false, # jan1 to jan31
            :f6 => be_true, # apr1 to apr30
            :f7 => be_true, # apr1 - same start / finish
            :f8 => be_false #nil/nil
        }
        test_data_in_range(@files, Date.parse("2011-03-01"), nil, mapping)


      end
      it "should work with end date only" do
        mapping = {
            :f1 => be_true, # jan1 to feb28
            :f2 => be_true, # jan1 to apr30
            :f3 => be_true, # feb1 to mar31
            :f4 => be_true, # mar1 to apr30
            :f5 => be_true, # jan1 to jan31
            :f6 => be_false, # apr1 to apr30
            :f7 => be_false, # apr1 - same start / finish
            :f8 => be_false #nil/nil
        }
        test_data_in_range(@files, nil, Date.parse("2011-03-01"), mapping)

      end
      it "should work with range" do

        mapping = {
            :f1 => be_true, # jan1 to feb28
            :f2 => be_true, # jan1 to apr30
            :f3 => be_true, # feb1 to mar31
            :f4 => be_false, # mar1 to apr30
            :f5 => be_true, # jan1 to jan31
            :f6 => be_false, # apr1 to apr30
            :f7 => be_false, # apr1 - same start / finish
            :f8 => be_false #nil/nil
        }

        test_data_in_range(@files, Date.parse("2010-01-01"), Date.parse("2011-02-01"), mapping)
      end

      it "should work with a single date in both fields" do

        mapping = {
            :f1 => be_false, # jan1 to feb28
            :f2 => be_true, # jan1 to apr30
            :f3 => be_false, # feb1 to mar31
            :f4 => be_true, # mar1 to apr30
            :f5 => be_false, # jan1 to jan31
            :f6 => be_true, # apr1 to apr30
            :f7 => be_true, # apr1 - same start / finish
            :f8 => be_false #nil/nil
        }

        test_data_in_range(@files, Date.parse("2011-04-01"), Date.parse("2011-04-01"), mapping)
      end
    end

    it "when searching with start date only should return all files which end on or after the given date" do
      search_result = DataFile.with_data_in_range(Date.parse("2011-03-01"), nil)
      search_result.size.should eq(5)
      search_result.pluck(:id).sort.should eq([@files[:f2], @files[:f3], @files[:f4], @files[:f6], @files[:f7]])

      search_result = DataFile.with_data_in_range(Date.parse("2011-04-30"), nil)
      search_result.size.should eq(3)
      search_result.pluck(:id).sort.should eq([@files[:f2], @files[:f4], @files[:f6]])

      search_result = DataFile.with_data_in_range(Date.parse("2011-05-01"), nil)
      search_result.size.should eq(0)
    end

    it "when searching with end date only should return all files that start on or before the given date" do
      search_result = DataFile.with_data_in_range(nil, Date.parse("2011-03-01"))
      search_result.size.should eq(5)
      search_result.pluck(:id).sort.should eq([@files[:f1], @files[:f2], @files[:f3], @files[:f4], @files[:f5]])

      search_result = DataFile.with_data_in_range(nil, Date.parse("2011-02-28"))
      search_result.size.should eq(4)
      search_result.pluck(:id).sort.should eq([@files[:f1], @files[:f2], @files[:f3], @files[:f5]])

      search_result = DataFile.with_data_in_range(nil, Date.parse("2011-01-01"))
      search_result.size.should eq(3)
      search_result.pluck(:id).sort.should eq([@files[:f1], @files[:f2], @files[:f5]])

      search_result = DataFile.with_data_in_range(nil, Date.parse("2010-12-31"))
      search_result.size.should eq(0)
    end

    it "when searching with both dates should only return files that have data falling in the range" do
      search_result = DataFile.with_data_in_range(Date.parse("2010-01-01"), Date.parse("2010-12-31"))
      search_result.size.should eq(0)

      search_result = DataFile.with_data_in_range(Date.parse("2010-01-01"), Date.parse("2011-01-01"))

      search_result.size.should eq(3)
      search_result.pluck(:id).sort.should eq([@files[:f1], @files[:f2], @files[:f5]])

      search_result = DataFile.with_data_in_range(Date.parse("2010-01-01"), Date.parse("2011-02-01"))
      search_result.size.should eq(4)
      search_result.pluck(:id).sort.should eq([@files[:f1], @files[:f2], @files[:f3], @files[:f5]])

      #single day
      search_result = DataFile.with_data_in_range(Date.parse("2011-02-01"), Date.parse("2011-02-01"))
      search_result.size.should eq(3)
      search_result.pluck(:id).sort.should eq([@files[:f1], @files[:f2], @files[:f3]])

      search_result = DataFile.with_data_in_range(Date.parse("2011-02-15"), Date.parse("2011-03-15"))
      search_result.size.should eq(4)
      search_result.pluck(:id).sort.should eq([@files[:f1], @files[:f2], @files[:f3], @files[:f4]])

      search_result = DataFile.with_data_in_range(Date.parse("2011-04-01"), Date.parse("2011-12-12"))
      search_result.size.should eq(4)
      search_result.pluck(:id).sort.should eq([@files[:f2], @files[:f4], @files[:f6], @files[:f7]])

      search_result = DataFile.with_data_in_range(Date.parse("2011-04-30"), Date.parse("2011-12-12"))
      search_result.size.should eq(3)
      search_result.pluck(:id).sort.should eq([@files[:f2], @files[:f4], @files[:f6]])

      search_result = DataFile.with_data_in_range(Date.parse("2011-05-01"), Date.parse("2011-12-12"))
      search_result.size.should eq(0)
    end
  end

  describe "Find files for station name" do
    it "should find only files with the matching metadata item" do
      f1 = Factory(:data_file)
      f2 = Factory(:data_file)
      f3 = Factory(:data_file)
      f4 = Factory(:data_file)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => f1)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "DEF", :data_file => f2)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "GHI", :data_file => f3)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => f4)
      Factory(:metadata_item, :key => "other key", :value => "ABC", :data_file => f3)
      DataFile.with_station_name_in(["ABC"]).collect(&:id).sort.should eq([f1.id, f4.id])
      DataFile.with_station_name_in(["ABC", "DEF"]).collect(&:id).sort.should eq([f1.id, f2.id, f4.id])
      DataFile.with_station_name_in(["ABC", "ASDF"]).collect(&:id).sort.should eq([f1.id, f4.id])
      DataFile.with_station_name_in(["ASDF"]).collect(&:id).sort.should eq([])
    end
  end

  describe "Getting set of column headings for searching" do
    it "Should include all mapped headers as well as unmapped headers from existing files" do
      df1 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfl", :data_file => df1)
      Factory(:column_detail, :name => "Temp", :data_file => df1)
      Factory(:column_detail, :name => "Humi", :data_file => df1)

      df2 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfll", :data_file => df2)
      Factory(:column_detail, :name => "SoilTemp", :data_file => df2)
      Factory(:column_detail, :name => "Humi", :data_file => df2)

      Factory(:column_mapping, :name => "Rainfall", :code => "Rnfl")
      Factory(:column_mapping, :name => "Rainfall", :code => "Rnfll")
      Factory(:column_mapping, :name => "Temperature", :code => "Temp")
      Factory(:column_mapping, :name => "Wind Speed", :code => "Wind")

      searchables = DataFile.searchable_column_names
      searchables.should eq(["Humi", "Rainfall", "SoilTemp", "Temperature", "Wind Speed"])
    end
  end

  describe "Find files with variables" do
    before(:each) do
      @f1 = Factory(:data_file)
      @f2 = Factory(:data_file)
      @f3 = Factory(:data_file)
      @f4 = Factory(:data_file)
      @f5 = Factory(:data_file)
      @f6 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfll", :data_file => @f1)
      Factory(:column_detail, :name => "Temp", :data_file => @f1)
      Factory(:column_detail, :name => "Humi", :data_file => @f1)
      Factory(:column_detail, :name => "Rnfl", :data_file => @f2)
      Factory(:column_detail, :name => "Rnfll", :data_file => @f3)
      Factory(:column_detail, :name => "Temp", :data_file => @f4)
      Factory(:column_detail, :name => "Blah", :data_file => @f5)
    end

    it "should work with single column name" do
      DataFile.with_any_of_these_columns(["Rnfll"]).pluck(:id).sort.should eq([@f1.id, @f3.id])
    end

    it "should work with multiple column names" do
      DataFile.with_any_of_these_columns(["Rnfll", "Temp"]).pluck(:id).sort.should eq([@f1.id, @f3.id, @f4.id])
    end

    it "should be empty if no matches" do
      DataFile.with_any_of_these_columns(["asdf", "dfg"]).should be_empty
    end

  end

  describe "Is time parsable method" do
    it "should return true only if format attribute is TOA5 or BAGIT" do
      Factory(:data_file, :format => nil).time_parsable?.should be_false
      Factory(:data_file, :format => 'asdf').time_parsable?.should be_false
      Factory(:data_file, :format => "TOA5").time_parsable?.should be_true
      Factory(:data_file, :format => "BAGIT", access_rights_type: 'Open', license: 'http://creativecommons.org/licenses/by/4.0').time_parsable?.should be_true
    end
  end

  describe "Column Mappings" do
    it "should return true if there are columns which are unmapped" do
      @data_file = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfll", :data_file => @data_file)
      Factory(:column_detail, :name => "Temp", :data_file => @data_file)
      @data_file.cols_unmapped?.should eq(true)
    end

    it "should return false if all columns mapped" do
      @data_file = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfll", :data_file => @data_file)
      Factory(:column_detail, :name => "Temp", :data_file => @data_file)
      Factory(:column_mapping, :code => "Rnfll")
      Factory(:column_mapping, :code => "Temp")
      @data_file.cols_unmapped?.should eq(false)

    end
  end

  describe "Renaming files" do
    it "should move the file and update path and filename" do
      old_path = Rails.root.join("tmp", "blah.txt")
      FileUtils.cp(Rails.root.join("samples/sample1.txt"), old_path)
      old_path.should exist

      data_file = Factory(:data_file, :path => old_path, :filename => "blah.txt")

      new_path = Rails.root.join("tmp", "another.txt")
      data_file.rename_to(new_path.to_s, "another.txt")
      data_file.reload
      data_file.path.should eq(new_path.to_s)
      data_file.filename.should eq("another.txt")
      old_path.should_not exist
      new_path.should exist
    end
  end

  describe "Checking Filepath" do
    it "should not update filename that has not not been edited" do
      old_path = set_up_data_file_path("blah.txt")
      old_path.should exist

      data_file = Factory(:data_file, :path => old_path.to_s, :filename => "blah.txt")
      data_file.rename_file("blah.txt", "blah.txt", "some_dir/")
      data_file.filename.should eq("blah.txt")
      data_file.path.should eq(old_path.to_s)
      old_path.should exist
      sample_file_path = Rails.root.join("samples/sample1.txt")
      FileUtils.compare_file(old_path.to_s, sample_file_path.to_s).should eq(true)
    end

    it "should update the filename and path if filename is edited" do
      old_path = set_up_data_file_path("blah.txt")
      data_file = Factory(:data_file, :path => old_path.to_s, :filename => "blah.txt")
      new_filename = "newfile.txt"
      new_filepath_dir = Rails.root.join("tmp")
      data_file.rename_file("blah.txt", new_filename, new_filepath_dir)
      new_path = Rails.root.join(new_filepath_dir, new_filename)
      data_file.filename.should eq(new_filename)
      data_file.path.should eq(new_path.to_s)
      old_path.should_not exist
      new_path.should exist
      # cleanup  (look up 'after each'/ 'after all')
      File.delete(new_path.to_s)
    end

  end

  describe "Updating data file" do
    it "should return false if there is no start date" do
      @data_file = Factory(:data_file, :end_time => "")
      result = @data_file.start_time_is_not_nil?
      result.should eq(false)
    end

    it "should return false if there is no end date" do
      @data_file = Factory(:data_file, :end_time => "")
      result = @data_file.start_time_is_not_nil?
      result.should eq(false)
    end
  end

  describe "Deleting Files/data" do

    it "should remove only/all column details associated with a file from the database" do
      df1 = Factory(:data_file)
      df1_cols = []
      df1_cols << Factory(:column_detail, :name => "Rnfl", :data_file => df1)
      df1_cols << Factory(:column_detail, :name => "Temp", :data_file => df1)

      df2 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfl", :data_file => df2)
      Factory(:column_detail, :name => "SoilTemp", :data_file => df2)

      all_cols = ColumnDetail.all
      df1.destroy
      ColumnDetail.all.should eq (all_cols - df1_cols)
    end

    it "should not remove any column mappings defined from columns in a deleted file" do
      df1 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfl", :data_file => df1)
      Factory(:column_detail, :name => "Temp", :data_file => df1)
      Factory(:column_mapping, :name => "Rainfall", :code => "Rnfl")
      Factory(:column_mapping, :name => "Temperature", :code => "Temp")

      searchables = DataFile.searchable_column_names
      searchables.should eq(["Rainfall", "Temperature"])

      df1.destroy

      searchables = DataFile.searchable_column_names
      searchables.should eq(["Rainfall", "Temperature"])
    end

    it "should remove all metadata records associated with a file from the database" do
      df1 = Factory(:data_file)
      df2 = Factory(:data_file)
      df3 = Factory(:data_file)

      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => df1)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => df2)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => df3)

      DataFile.with_station_name_in(["ABC"]).collect(&:id).sort.should eq([df1.id, df2.id, df3.id])
      df1.destroy
      DataFile.with_station_name_in(["ABC"]).collect(&:id).sort.should eq([df2.id, df3.id])
      MetadataItem.find_by_data_file_id(df1).should eq nil
    end

    it "should remove all cart items for the data file" do
      df1 = Factory(:data_file)
      df2 = Factory(:data_file)
      user1 = Factory(:user)
      user2 = Factory(:user)
      user1.cart_items << df1
      user1.cart_items << df2
      user2.cart_items << df1

      user1.cart_items.size.should eq(2)
      user2.cart_items.size.should eq(1)

      df1.destroy

      user1.reload
      user2.reload
      user1.cart_items.size.should eq(1)
      user2.cart_items.size.should eq(0)
    end

  end

  describe "overlaps" do

    describe "Getting files from same station with same table name" do
      it "Should return files that are RAW, TOA5 and have same station and table name" do
        toa1 = create_toa5('s1', 't1')
        times = {:start_time => Time.parse("2012-02-01 03:45 UTC"), :end_time => Time.parse("2012-04-03 14:44 UTC")}
        txt = Factory(:data_file, times.merge(:format => nil))
        diff_station = create_toa5('s2', 't1')
        diff_table = create_toa5('s1', 't2')
        same1 = create_toa5('s1', 't1')
        same2 = create_toa5('s1', 't1')
        diff_both = create_toa5('s2', 't2')
        no_station_table = Factory(:data_file, times.merge(:format => FileTypeDeterminer::TOA5, :file_processing_status => 'RAW'))
        not_raw = create_toa5('s1', 't1', 'PROCESSED')

        toa1.raw_toa5_files_with_same_station_name_and_table_name.pluck(:id).sort.should eq([same1.id, same2.id].sort)
      end
    end
    describe "Categorising overlap" do
      let(:start_time) { Time.parse('2012-02-01 03:45:03 UTC') }
      let(:end_time) { Time.parse('2012-02-20 15:23:59 UTC') }
      let(:existing) { create_toa5_with_dates(start_time, end_time) }
      describe "Should correctly identify files that do not overlap at all" do
        it "file completely before" do
          existing.categorise_overlap(create_toa5_with_dates(start_time - 1.day, start_time - 1.second)).should eq('NONE')
        end
        it "file completely after" do
          existing.categorise_overlap(create_toa5_with_dates(end_time + 1.second, end_time + 1.day)).should eq('NONE')
        end
      end
      describe "Should correctly identify files that are safe (i.e. are supersets AND content matches)" do
        before(:each) { FileOverlapContentChecker.stub(:new).and_return(double(:content_matches => true)) }
        it "exact same dates" do
          existing.categorise_overlap(create_toa5_with_dates(start_time, end_time)).should eq('SAFE')
        end
        it "starts before, ends at same time" do
          existing.categorise_overlap(create_toa5_with_dates(start_time - 1.day, end_time)).should eq('SAFE')
        end
        it "starts before, ends after" do
          existing.categorise_overlap(create_toa5_with_dates(start_time - 1.second, end_time + 1.day)).should eq('SAFE')
        end
        it "starts at same time, ends after" do
          existing.categorise_overlap(create_toa5_with_dates(start_time, end_time + 1.second)).should eq('SAFE')
        end
      end
      describe "Should correctly identify files that are unsafe due to content mismatch (i.e. are supersets but content mismatched)" do
        before(:each) { FileOverlapContentChecker.stub(:new).and_return(double(:content_matches => false)) }
        it "exact same dates" do
          existing.categorise_overlap(create_toa5_with_dates(start_time, end_time)).should eq('UNSAFE')
        end
        it "starts before, ends at same time" do
          existing.categorise_overlap(create_toa5_with_dates(start_time - 1.day, end_time)).should eq('UNSAFE')
        end
        it "starts before, ends after" do
          existing.categorise_overlap(create_toa5_with_dates(start_time - 1.second, end_time + 1.day)).should eq('UNSAFE')
        end
        it "starts at same time, ends after" do
          existing.categorise_overlap(create_toa5_with_dates(start_time, end_time + 1.second)).should eq('UNSAFE')
        end
      end
      describe "Should correctly identify files are unsafe due to dates (i.e. are subsets or mismatched overlaps)" do
        it "starts before, ends during" do
          existing.categorise_overlap(create_toa5_with_dates(start_time - 1.hour, end_time - 1.minute)).should eq('UNSAFE')
        end
        it "starts at same time, ends during" do
          existing.categorise_overlap(create_toa5_with_dates(start_time, end_time - 1.second)).should eq('UNSAFE')
        end
        it "starts after, ends before" do
          existing.categorise_overlap(create_toa5_with_dates(start_time + 1.second, end_time - 1.day)).should eq('UNSAFE')
        end
        it "starts after, ends at same time" do
          existing.categorise_overlap(create_toa5_with_dates(start_time + 1.minute, end_time - 1.hour)).should eq('UNSAFE')
        end
        it "starts after, ends after" do
          existing.categorise_overlap(create_toa5_with_dates(start_time + 1.hour, end_time + 1.hour)).should eq('UNSAFE')
        end
      end
    end
  end
end

def make_data_file!(start_time, end_time, path, station_name, table_name, status=DataFile::STATUS_RAW)
  data_file = Factory(:data_file, :start_time => start_time, :end_time => end_time, :format => FileTypeDeterminer::TOA5, :path => path, :file_processing_status => status)

  data_file.metadata_items.create!(:key => MetadataKeys::STATION_NAME_KEY, :value => station_name)
  data_file.metadata_items.create!(:key => MetadataKeys::TABLE_NAME_KEY, :value => table_name)

  data_file
end

def create_toa5(station_name, table_name, status='RAW')
  df = Factory(:data_file, {:start_time => Time.parse("2012-02-01 03:45 UTC"), :end_time => Time.parse("2012-04-03 14:44 UTC"), :format => FileTypeDeterminer::TOA5, :file_processing_status => status})
  df.metadata_items.create!(:key => MetadataKeys::STATION_NAME_KEY, :value => station_name)
  df.metadata_items.create!(:key => MetadataKeys::TABLE_NAME_KEY, :value => table_name)
  df
end

def create_toa5_with_dates(start_time, end_time)
  df = Factory(:data_file, {:start_time => start_time, :end_time => end_time, :format => FileTypeDeterminer::TOA5, :file_processing_status => 'RAW'})
  df.metadata_items.create!(:key => MetadataKeys::STATION_NAME_KEY, :value => 'S1')
  df.metadata_items.create!(:key => MetadataKeys::TABLE_NAME_KEY, :value => 'S2')
  df
end

def set_up_data_file_path(filename)
  path = Rails.root.join("tmp", filename)
  FileUtils.cp(Rails.root.join("samples/sample1.txt"), path)
  path
end

