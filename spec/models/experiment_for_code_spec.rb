require 'spec_helper'

describe ExperimentForCode do

  describe "Associations" do
    it { should belong_to(:experiment) }
  end

  describe "Validations" do
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:name) }
  end
end
