class RenameResearcherRoleToInstUser < ActiveRecord::Migration
  def change
    if Role.exists?(:name => "Researcher")
      r = Role.where(:name => "Researcher").first
      r.name = "Institutional User"
      r.save
    end
    unless Role.exists?(:name => "Non-Institutional User")
      Role.create!(:name => "Non-Institutional User")
    end
  end
end
