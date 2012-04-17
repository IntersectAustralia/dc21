# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :published_collection do
      name "MyString"
      created_by_id 1
      rif_cs_file_path "MyString"
      zip_file_path "MyString"
    end
end