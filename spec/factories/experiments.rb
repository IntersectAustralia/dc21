# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :experiment do
    sequence(:name) { |n| "exp-#{n}" }
    start_date "2012-02-09"
    end_date "2012-02-10"
    subject "MyString"
    access_rights "http://creativecommons.org/licenses/by/3.0/au"
    association :facility
  end
end