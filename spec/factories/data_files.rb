# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :data_file do
<<<<<<< HEAD
      filename "MyString"
      path "MyString"
    end
end
=======
    filename "a-filename"
    path "a-path"
    association :created_by, :factory => :user
  end
end
>>>>>>> 1d46400ca842a4d9edebbb28f228961975c565ee
