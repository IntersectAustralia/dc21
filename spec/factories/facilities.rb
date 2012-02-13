# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facility do
    name "a-name"
    sequence(:code) { |n| "code-#{n}" }
  end
end
