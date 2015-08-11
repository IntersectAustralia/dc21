# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :data_file do
    sequence(:filename) { |n| "file-#{n}" }
    path "/some/path/that/does/not/exist"
    association :created_by, :factory => :user
    association :published_by, :factory => :user
    association :experiment
    file_processing_status "RAW"
    file_size 10000
  end

  factory :package do
    sequence(:filename) { |n| "file-#{n}" }
    path "/some/path/that/does/not/exist"
    association :created_by, :factory => :user
    association :published_by, :factory => :user
    association :experiment
    file_processing_status "PACKAGE"
    access_rights_type Package::ACCESS_RIGHTS_OPEN
    title "title"
    file_size 35642
  end
end
