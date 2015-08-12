# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :language do
    sequence(:language_name) { |n| "Language-#{n}" }
  end
end