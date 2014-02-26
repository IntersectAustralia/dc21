class AccessGroupUser < ActiveRecord::Base
  belongs_to :access_group
  belongs_to :user

  validates_presence_of :access_group
  validates_presence_of :user
end