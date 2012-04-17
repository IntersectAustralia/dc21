require 'spec_helper'

describe PublishedCollection do
  describe "Creating a valid record" do
    it "should work with all required fields filled in" do
      PublishedCollection.create(name: "Coll", rif_cs_file_path: "blah", zip_file_path: "blah", created_by: Factory(:user)).should be_true
    end
  end

  describe "Associations" do
    it { should belong_to(:created_by) }
  end

  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:created_by) }
  end
end
