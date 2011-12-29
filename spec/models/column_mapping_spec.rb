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
end
