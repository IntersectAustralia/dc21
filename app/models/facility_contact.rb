class FacilityContact < ActiveRecord::Base
  belongs_to :facility
  belongs_to :user

  #validates_uniqueness_of :primary, :scope => :facility_id
  validates_presence_of :facility, :user
end
