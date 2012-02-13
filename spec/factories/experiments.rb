# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :experiment do
    name "MyString"
    description "MyText"
    start_date "2012-02-09"
    end_date "2012-02-09"
    subject "MyString"
    access_rights "MyString"
    association :facility
  end
end