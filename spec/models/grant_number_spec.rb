require 'spec_helper'

describe GrantNumber do
  describe "Validations" do
    it { should validate_presence_of(:grant_id) }
  end

  describe "Associations" do
    it { should belong_to(:data_file) }
  end
end
