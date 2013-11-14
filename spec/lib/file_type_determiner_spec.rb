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

  let(:toa5_dat_quoted) do
    path = Rails.root.join('spec/samples', 'toa5_quoted.dat')
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

  let(:wav) do
    path = Rails.root.join('samples', 'Test_SR.wav')
    Factory(:data_file, :path => path, :filename => 'Test_SR.wav')
  end

  let(:file_type_determiner) {
    FileTypeDeterminer.new
  }

  describe "Should identify valid TOA5 files regardless of file extension" do

    it "should identify TOA5 files with dat extension and correct header" do
      format = file_type_determiner.identify_file(toa5_dat)
      format.should eq(FileTypeDeterminer::TOA5)
    end

    it "should identify TOA5 files with dat extension and correct header with quotes" do
      format = file_type_determiner.identify_file(toa5_dat_quoted)
      format.should eq(FileTypeDeterminer::TOA5)
    end

    it "should identify TOA5 files with txt extension and correct header" do
      format = file_type_determiner.identify_file(toa5_txt)
      format.should eq(FileTypeDeterminer::TOA5)
    end

    it "should identify TOA5 files with csv extension and correct header" do
      format = file_type_determiner.identify_file(toa5_csv)
      format.should eq(FileTypeDeterminer::TOA5)
    end

    it "should identify WAV file" do
      format = file_type_determiner.identify_file(wav)
      format.should eq('audio/x-wav')
    end
  end

  describe "Unidentifiable files" do

    it "should NOT identify files with DAT extension but no TOA5 header" do
      format = file_type_determiner.identify_file(unknown_dat)
      format.should eq("text/plain")
    end

    it "should NOT identify files with DAT extension but which are empty" do
      format = file_type_determiner.identify_file(empty_dat)
      format.should_not eq(FileTypeDeterminer::TOA5)
      format.should_not be_nil
    end

    it "should NOT identify files with DAT extension but no TOA5 header - binary format" do
      format = file_type_determiner.identify_file(jpg)
      format.should eq('image/jpeg')
    end

  end
end
