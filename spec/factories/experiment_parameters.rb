# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :experiment_parameter do
      association :parameter_category
      association :parameter_sub_category
      association :parameter_modification
      amount "9.99"
      units "MyString"
      comments "MyString"
    end
end