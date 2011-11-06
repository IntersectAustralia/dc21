class Permission < ActiveRecord::Base

  validates :entity, :presence => true
  validates :action, :presence => true

end
