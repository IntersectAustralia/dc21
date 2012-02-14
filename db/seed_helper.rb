def create_roles
  Role.delete_all

  Role.create!(:name => "Administrator")
  Role.create!(:name => "Researcher")
  Role.create!(:name => "API Uploader")

end

