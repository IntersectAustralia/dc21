# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :parameter_sub_category do
    name "MyString"
    association :parameter_category
  end
end
