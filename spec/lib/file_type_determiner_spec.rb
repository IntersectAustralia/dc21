require 'spec_helper'

describe FileTypeDeterminer do

  let(:unknown_dat) do
    path = Rails.root.join('spec/samples', 'unknown.dat')
    Factory(:data_file, :path => path, :filename => 'unknown.dat')
  end

  let(:empty_dat) do
    path = Rails.root.join('spec/samples', 'empty.dat')
    Factory(:data_file, :path => path, :filename => 'empty.dat')
  end

  let(:toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory(:data_file, :path => path, :filename => 'toa5.dat')
  end

  let(:toa5_txt) do
    path = Rails.root.join('spec/samples', 'toa5.txt')
    Factory(:data_file, :path => path, :filename => 'toa5.txt')
  end

  let(:toa5_csv) do
    path = Rails.root.join('spec/samples', 'toa5.csv')
    Factory(:data_file, :path => path, :filename => 'toa5.csv')
  end

  let(:jpg) do
    path = Rails.root.join('spec/samples', 'really-a-jpg.dat')
    Factory(:data_file, :path => path, :filename => 'really-a-jpg.dat')
  end

  let(:file_type_determiner) {
    FileTypeDeterminer.new
  }

  describe "Should identify valid TOA5 files regardless of file extension" do

    it "should identify TOA5 files with dat extension and correct header" do
      known, format = file_type_determiner.identify_file(toa5_dat)
      known.should be_true
      format.should eq(FileTypeDeterminer::TOA5)
    end

    it "should identify TOA5 files with txt extension and correct header" do
      known, format = file_type_determiner.identify_file(toa5_txt)
      known.should be_true
      format.should eq(FileTypeDeterminer::TOA5)
    end

    it "should identify TOA5 files with csv extension and correct header" do
      known, format = file_type_determiner.identify_file(toa5_csv)
      known.should be_true
      format.should eq(FileTypeDeterminer::TOA5)
    end
  end

  describe "Unidentifiable files" do

    it "should NOT identify files with DAT extension but no TOA5 header" do
      known, format = file_type_determiner.identify_file(unknown_dat)
      known.should be_false
      format.should be_nil
    end

    it "should NOT identify files with DAT extension but which are empty" do
      known, format = file_type_determiner.identify_file(empty_dat)
      known.should be_false
      format.should be_nil
    end

    it "should NOT identify files with DAT extension but no TOA5 header - binary format" do
      known, format = file_type_determiner.identify_file(jpg)
      known.should be_false
      format.should be_nil
    end
  end
end
