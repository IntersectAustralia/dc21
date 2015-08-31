require 'spec_helper'

describe ColumnMapping do
  describe "Create valid object" do
    it "creating an object with the minimum fields should succeed" do
      Factory(:column_mapping).should be_valid
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:code) }
    it { should validate_length_of(:code).is_at_most(255) }
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
      Factory(:column_mapping, :code => "humidity", :name => "humidity")
      Factory(:column_mapping, :code => "humi", :name => "humidity")
      Factory(:column_mapping, :code => "asdf", :name => "stuff")

      Factory(:column_detail, :name => "new")
      Factory(:column_detail, :name => "different")
      Factory(:column_detail, :name => "humidity")

      output = ColumnMapping.mapped_column_names_for_search
      output.size.should eq(3)
      output[0].should eq(["humidity", ["humi", "humidity"]])
      output[1].should eq(["stuff", ["asdf"]])
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
end
