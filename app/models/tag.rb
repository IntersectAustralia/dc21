class Tag < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false

  default_scope order(:name)
end
