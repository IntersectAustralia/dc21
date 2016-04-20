# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contributor do
      sequence(:name) { |n| "CONT-#{n}" }
    end
end