require 'spec_helper'

describe ColumnMapping do
  describe "Create valid object" do
    it "creating an object with the minimum fields should succeed" do
      Factory(:column_mapping).should be_valid
    end
  end

  describe "Validations" do
    it { should validate_presence_of(:code) }
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

  describe "Map names to codes" do
    it "should map those that do exist and leave those that are missing" do
      Factory(:column_mapping, :code => "abc", :name => "def")
      Factory(:column_mapping, :code => "def", :name => "def")
      Factory(:column_mapping, :code => "ghi", :name => "jkl")
      Factory(:column_mapping, :code => "mno", :name => "pqr")
      ColumnMapping.map_names_to_codes(["def", "pqr", "blah"]).sort.should eq(["abc", "blah", "def", "mno"])
    end
  end

  describe "Check column mapping" do
    it "should check whether column mapping is correct" do
      test = Factory(:column_mapping, :code => "abc", :name => "def")
      test.check_col_mapping("abc").should eq(test)
      test.check_col_mapping("def").should eq(nil)
    end
  end

end
