# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :metadata_item do
      key "some-key"
      value "some-value"
      association :data_file
    end
end
