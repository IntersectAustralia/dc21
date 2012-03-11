class ParameterModification < ActiveRecord::Base

  validates_presence_of :name

  scope :by_name, order(:name)
end
