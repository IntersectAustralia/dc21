# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :access_group do
    sequence(:name) { |n| "name-#{n}"}
    association :primary_user, :factory => :user
  end
end