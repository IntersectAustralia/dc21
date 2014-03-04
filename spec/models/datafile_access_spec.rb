require 'spec_helper'

describe DatafileAccess do
  describe "Validations" do
    it { should validate_presence_of(:data_file) }
    it { should validate_presence_of(:access_group) }
  end

end
