require 'spec_helper'

describe ColumnMapping do
  describe "Create valid object" do
    it "creating an object with the minimum fields should succeed" do
      Factory(:column_mapping).should be_valid
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:code) }
    it { should ensure_length_of(:code).is_at_most(255) }
    it { should validate_presence_of(:name) }
    it "should validate uniqueness of code" do
      Factory(:column_mapping)
      should validate_uniqueness_of(:code)
    end
  end

  describe "Code to name map" do
    it "should return a map containing all codes and names" do
      Factory(:column_mapping, :code => "abc", :name => "def")
      Factory(:column_mapping, :code => "def", :name => "def")
      Factory(:column_mapping, :code => "ghi", :name => "jkl")
      map = ColumnMapping.code_to_name_map
      map.size.should eq(3)
      map["abc"].should eq("def")
      map["def"].should eq("def")
      map["ghi"].should eq("jkl")
    end
  end

  describe "Grouping mapped and unmapped column names" do
    it "should return an array of arrays with the mappings organised by name, plus unmapped ones at the end" do
      Factory(:column_mapping, :code => "rn", :name => "Rainfall")
      Factory(:column_mapping, :code => "rainfall", :name => "Rainfall")
      Factory(:column_mapping, :code => "rnf", :name => "Rainfall")
      Factory(:column_mapping, :code => "humidity", :name => "Humidity")
      Factory(:column_mapping, :code => "humi", :name => "Humidity")
      Factory(:column_mapping, :code => "asdf", :name => "Stuff")

      Factory(:column_detail, :name => "new")
      Factory(:column_detail, :name => "different")

      output = ColumnMapping.mapped_column_names_for_search
      output.size.should eq(4)
      output[0].should eq(["Humidity", ["humi", "humidity"]])
      output[1].should eq(["Rainfall", ["rainfall", "rn", "rnf"]])
      output[2].should eq(["Stuff", ["asdf"]])
      output[3].should eq(["Unmapped", ["different", "new"]])
    end

    it "should return an array of arrays with the mappings organised by name, plus unmapped ones at the end" do
      Factory(:column_mapping, :code => "rn", :name => "Rainfall")
      Factory(:column_mapping, :code => "rainfall", :name => "Rainfall")
      Factory(:column_mapping, :code => "rnf", :name => "Rainfall")
      Factory(:column_mapping, :code => "humidity", :name => "Humidity")
      Factory(:column_mapping, :code => "humi", :name => "Humidity")
      Factory(:column_mapping, :code => "asdf", :name => "Stuff")

      Factory(:column_detail, :name => "new")
      Factory(:column_detail, :name => "different")

      output = ColumnMapping.mapped_column_names_for_search
      output.size.should eq(4)
      output[0].should eq(["Humidity", ["humi", "humidity"]])
      output[1].should eq(["Rainfall", ["rainfall", "rn", "rnf"]])
      output[2].should eq(["Stuff", ["asdf"]])
      output[3].should eq(["Unmapped", ["different", "new"]])
    end

    it "should handle the case where we have columns that are named with the same name as a mapped name" do
      pending("Need to confirm the expected behaviour for this")
      Factory(:column_mapping, :code => "humidity", :name => "Humidity")
      Factory(:column_mapping, :code => "humi", :name => "Humidity")
      Factory(:column_mapping, :code => "asdf", :name => "Stuff")

      Factory(:column_detail, :name => "new")
      Factory(:column_detail, :name => "different")
      Factory(:column_detail, :name => "Humidity")

      output = ColumnMapping.mapped_column_names_for_search
      output.size.should eq(3)
      output[0].should eq(["Humidity", ["humi", "humidity"]])
      output[1].should eq(["Stuff", ["asdf"]])
      output[2].should eq(["Unmapped", ["different", "new"]])
    end

    it "should return only unmapped if nothing is mapped" do
      Factory(:column_detail, :name => "new")
      Factory(:column_detail, :name => "different")

      output = ColumnMapping.mapped_column_names_for_search
      output.size.should eq(1)
      output[0].should eq(["Unmapped", ["different", "new"]])
    end

    it "should exclude unmapped if everything is mapped" do
      Factory(:column_mapping, :code => "humidity", :name => "Humidity")
      Factory(:column_mapping, :code => "humi", :name => "Humidity")
      Factory(:column_mapping, :code => "asdf", :name => "Stuff")

      Factory(:column_detail, :name => "asdf")
      Factory(:column_detail, :name => "humi")

      output = ColumnMapping.mapped_column_names_for_search
      output.size.should eq(2)
      output[0].should eq(["Humidity", ["humi", "humidity"]])
      output[1].should eq(["Stuff", ["asdf"]])
    end

  end

  describe "Check column mapping" do
    it "should check whether column mapping is correct" do
      test = Factory(:column_mapping, :code => "abc", :name => "def")
      test.check_col_mapping("abc").should eq(test)
      test.check_col_mapping("def").should eq(nil)
    end
    it "should check whether column mapping exists in given array" do
      test = ColumnMapping.new(:code => "abc", :name => "def")
      test2 = ColumnMapping.new(:code => "bcd", :name => "efg")
      test3 = ColumnMapping.new(:code => "abc", :name => "fgh")
      test4 = ColumnMapping.new(:code => "cde", :name => "ghi")
      mappings = [test2, test3]
      test.check_code_exists?(mappings).should eq(true)
      mappings = [test2, test4]
      test.check_code_exists?(mappings).should eq(false)
    end
  end

end
