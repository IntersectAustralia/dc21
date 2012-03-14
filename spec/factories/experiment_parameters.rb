# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :experiment_parameter do
      association :parameter_category
      association :parameter_sub_category
      association :parameter_modification
      association :parameter_unit
      association :experiment
      amount "9.99"
      comments "MyString"
    end
end