class RenameResearcherRoleToInstUser < ActiveRecord::Migration
  def change
    if Role.exists?(:name => "Researcher")
      Role.find_by_name("Researcher").update_attribute(:name, "Institutional User")
    end
    unless Role.exists?(:name => "Non-Institutional User")
      Role.create!(:name => "Non-Institutional User")
    end
  end
end
