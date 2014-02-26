# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :access_group_user do
    association :access_group
    association :user
    primary false
  end
end