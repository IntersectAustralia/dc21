# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facility_contact do
      association :facility
      association :user
      primary false
    end
end