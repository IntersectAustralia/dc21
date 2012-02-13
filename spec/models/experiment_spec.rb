require 'spec_helper'

describe Experiment do
  describe "Associations" do
    it { should belong_to(:facility) }
  end
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:facility_id) }
  end
end
