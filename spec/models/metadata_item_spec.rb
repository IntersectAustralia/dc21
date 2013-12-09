require 'spec_helper'

describe MetadataItem do
  describe "Associations" do
    it { should belong_to(:data_file) }
  end

  describe "Validations" do
    it { should validate_presence_of(:data_file_id) }
    it { should validate_presence_of(:key) }
    it { should validate_presence_of(:value) }
  end

  describe "Scopes" do
    it "Should be able to find metadata items for a certain key and set of values" do
      item_1 = Factory(:metadata_item, :key => "mykey", :value => "ABC").id
      item_2 = Factory(:metadata_item, :key => "mykey", :value => "DEF").id
      item_3 = Factory(:metadata_item, :key => "mykey", :value => "GHI").id
      item_4 = Factory(:metadata_item, :key => "anotherkey", :value => "ABC").id
      item_5 = Factory(:metadata_item, :key => "mykey", :value => "ABC").id
      item_6 = Factory(:metadata_item, :key => "anotherkey", :value => "DEF").id
      MetadataItem.for_key_with_value_in("mykey", ["ABC", "DEF"]).pluck(:id).sort.should eq([item_1, item_2, item_5])
      MetadataItem.for_key_with_value_in("mykey", ["DEF"]).pluck(:id).sort.should eq([item_2])
      MetadataItem.for_key_with_value_in("nokey", ["DEF"]).pluck(:id).sort.should eq([])
      MetadataItem.for_key_with_value_in("anotherkey", ["DEF"]).pluck(:id).sort.should eq([item_6])
    end
  end
end
