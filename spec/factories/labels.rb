# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :label do
    sequence(:name) { |n| "Label-#{n}" }
  end
end