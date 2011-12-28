# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :column_mapping do
    sequence(:code) { |n| "code-#{n}" }
    name "a-name"
  end
end