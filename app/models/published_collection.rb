class PublishedCollection < ActiveRecord::Base

  belongs_to :created_by, :class_name => "User"

  validates_presence_of :name
  validates_presence_of :created_by
  validates_uniqueness_of :name, :case_sensitive => false

end
