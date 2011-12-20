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
end
