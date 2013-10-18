class SystemConfiguration < ActiveRecord::Base

  acts_as_singleton
  validates_presence_of :name, :level1, :level1_plural, :level2, :level2_plural
  validates_length_of :name, :maximum => 20

end
