require 'spec_helper'

describe Language do
  describe "Validations" do
    it { should validate_presence_of(:language_name) }
  end
end
