# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :column_detail do
    name "Col1"
    association :data_file
  end
end
