require 'spec_helper'

describe Toa5Subsetter do

  let(:toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory(:data_file, :path => path, :filename => 'toa5.dat')
  end

  let(:toa5_quoted_dat) do
    path = Rails.root.join('spec/samples', 'toa5_quoted.dat')
    Factory(:data_file, :path => path, :filename => 'toa5_quoted.dat')
  end

  let(:not_really_toa5) do
    path = Rails.root.join('spec/samples', 'not-really-toa5.dat')
    Factory(:data_file, :path => path, :filename => 'not-really-toa5.dat')
  end

  describe "valid file" do
    it "should extract the header rows and matching date rows when searching with both from and to date" do
      data_file = toa5_dat
      temp_dir = Dir.mktmpdir
      Toa5Subsetter.extract_matching_rows_to(data_file, temp_dir, "2011-10-09", "2011-10-14")
      output = File.open(File.join(temp_dir, data_file.filename))

      expected_file = Rails.root.join("spec/samples", "toa5_subsetted_range.dat")
      output.should be_same_file_as(expected_file)
    end

    it "should extract the header rows and matching date rows when searching with from date only" do
      data_file = toa5_dat
      temp_dir = Dir.mktmpdir
      Toa5Subsetter.extract_matching_rows_to(data_file, temp_dir, "2011-10-09", nil)
      output = File.open(File.join(temp_dir, data_file.filename))

      expected_file = Rails.root.join("spec/samples", "toa5_subsetted_from_only.dat")
      output.should be_same_file_as(expected_file)
    end

    it "should extract the header rows and matching date rows when searching with to date only" do
      data_file = toa5_dat
      temp_dir = Dir.mktmpdir
      Toa5Subsetter.extract_matching_rows_to(data_file, temp_dir, nil, "2011-10-14")
      output = File.open(File.join(temp_dir, data_file.filename))

      expected_file = Rails.root.join("spec/samples", "toa5_subsetted_to_only.dat")
      output.should be_same_file_as(expected_file)
    end
  end

  describe "quoted, comma separated files should work too" do
    it "should extract the header rows and matching date rows when searching with both from and to date" do
      data_file = toa5_quoted_dat
      temp_dir = Dir.mktmpdir
      Toa5Subsetter.extract_matching_rows_to(data_file, temp_dir, "2011-10-09", "2011-10-14")
      output = File.open(File.join(temp_dir, data_file.filename))

      expected_file = Rails.root.join("spec/samples", "toa5_quoted_subsetted_range.dat")
      output.should be_same_file_as(expected_file)
    end
  end

  describe "invalid file" do
    it "should fail gracefully" do
      pending
    end
  end
end
