class FacilityContact < ActiveRecord::Base
  belongs_to :facility
  belongs_to :user

  validates_presence_of :facility, :user
end
