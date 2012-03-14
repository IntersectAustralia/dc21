require 'spec_helper'

describe ParameterUnit do
  describe "Validations" do
    it "object is valid with the basic info filled" do
      ParameterUnit.new(name: "Blah").should be_valid
    end

    it { should validate_presence_of(:name) }
  end
end
