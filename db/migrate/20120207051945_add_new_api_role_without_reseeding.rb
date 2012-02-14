class AddNewApiRoleWithoutReseeding < ActiveRecord::Migration
  #Adds / removes the
  def up
    if Role.count > 0 && Role.find_by_name("API Uploader").nil?
      say 'adding new role API Uploader'
      Role.create!(:name => "API Uploader")
    end
  end

  def down
    # If we have some roles (ie not a blank db)
      # Find the role
      # Destroy that roll unless it also doesn't exist
      # SKIPPED: Make any users who had that role into a researcher
    if Role.count > 0
      role = Role.find_by_name("API Uploader")
      #affected_users = role.users
      unless role.nil?
        say 'removing API Uploader role'
        say 'Affected Users (who now have no role):'
        role.users.each do |user|
          say "=> #{user.first_name} #{user.last_name}"
        end
        role.destroy

      end

      #affected_users.each do |u|
      #  u.role = Role.find_all_by_name("Researcher")
      #end
    end

  end
end
