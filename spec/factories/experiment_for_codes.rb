# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :experiment_for_code do
      association :experiment
      url "MyString"
      name "MyString"
    end
end