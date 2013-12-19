require 'spec_helper'

describe FileOverlapContentChecker do

  describe 'Identical dates' do
    it 'Should return true when content matches' do
      old = create_from_sample('8_9_10_oct.dat')
      new = create_from_sample('8_9_10_oct.dat', 'new.dat')
      FileOverlapContentChecker.new(old, new).content_matches.should be_true
    end
    it 'Should return false when content mismatched' do
      old = create_from_sample('8_9_10_oct.dat')
      new = create_from_sample('8_9_10_oct_altered.dat')
      FileOverlapContentChecker.new(old, new).content_matches.should be_false
    end
  end
  describe 'New file starts before, ends at same time' do
    it 'Should return true when content matches' do
      old = create_from_sample('8_9_10_oct.dat')
      new = create_from_sample('6_7_8_9_10_oct.dat')
      FileOverlapContentChecker.new(old, new).content_matches.should be_true
    end
    it 'Should return false when content mismatched' do
      old = create_from_sample('8_9_10_oct.dat')
      new = create_from_sample('6_7_8_9_10_oct_altered.dat')
      FileOverlapContentChecker.new(old, new).content_matches.should be_false
    end
  end
  describe 'New file starts before, ends after' do
    it 'Should return true when content matches' do
      old = create_from_sample('8_9_10_oct.dat')
      new = create_from_sample('6_7_8_9_10_11_oct.dat')
      FileOverlapContentChecker.new(old, new).content_matches.should be_true
    end
    it 'Should return false when content mismatched' do
      old = create_from_sample('8_9_10_oct.dat')
      new = create_from_sample('6_7_8_9_10_11_oct_altered.dat')
      FileOverlapContentChecker.new(old, new).content_matches.should be_false
    end
  end
  describe 'New file starts at same time, ends after' do
    it 'Should return true when content matches' do
      old = create_from_sample('8_9_10_oct.dat')
      new = create_from_sample('8_9_10_11_oct.dat')
      FileOverlapContentChecker.new(old, new).content_matches.should be_true
    end
    it 'Should return false when content mismatched' do
      old = create_from_sample('8_9_10_oct.dat')
      new = create_from_sample('8_9_10_11_oct_altered.dat')
      FileOverlapContentChecker.new(old, new).content_matches.should be_false
    end
  end
  describe 'Edge cases' do
    describe 'Where the start and/or end lines don\'t match up' do
      it 'should handle where the first line does not match' do
        old = create_from_sample('8_9_10_oct.dat')
        new = create_from_sample('8_9_10_11_oct_first_line_altered.dat')
        FileOverlapContentChecker.new(old, new).content_matches.should be_false
      end
      it 'should handle where the first line does not match' do
        old = create_from_sample('8_9_10_oct.dat')
        new = create_from_sample('8_9_10_11_oct_last_line_altered.dat')
        FileOverlapContentChecker.new(old, new).content_matches.should be_false
      end
    end
  end
end


def create_from_sample(sample_name, name_as=nil)
  path = Rails.root.join('samples/overlap_tests', sample_name).to_s
  data_file = DataFile.new(
                           :filename => name_as ? name_as : sample_name,
                           :file_processing_status => DataFile::STATUS_RAW,
                           :experiment_id => Factory(:experiment).id,
                           :file_processing_description => 'description',
                           :file_size => 0)
  data_file.path = path
  data_file.created_by = Factory(:user)
  format = FileTypeDeterminer.new.identify_file(data_file)
  data_file.format = format

  data_file.save!
  MetadataExtractor.new.extract_metadata(data_file, format) if format
  data_file.reload
end