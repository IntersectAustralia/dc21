require 'spec_helper'

describe Experiment do
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:subject) }
  end
end
