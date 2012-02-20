# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facility do
    sequence(:name) { |n| "name-#{n}" }
    sequence(:code) { |n| "code-#{n}" }
    #association :primary_contactable, :factory => :user
  end
end
