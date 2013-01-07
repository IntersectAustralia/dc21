# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :cart_item do
    association :data_file
    association :user
  end
end