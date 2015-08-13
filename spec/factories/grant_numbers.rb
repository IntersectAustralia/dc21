# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :grant_number do
    sequence(:name) { |n| "GN-#{n}" }
  end
end