require 'spec_helper'

describe AccessGroup do
  describe "Validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:primary_user) }
  end

  describe "Associations" do
    it { should have_many(:users)}
  end
end