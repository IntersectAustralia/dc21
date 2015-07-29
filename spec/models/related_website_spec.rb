require 'spec_helper'

describe RelatedWebsite do
  describe "Validations" do
    it { should validate_presence_of(:url) }
  end

  describe "Associations" do
    it { should belong_to(:data_file) }
  end
end
