class ParameterCategory < ActiveRecord::Base

  validates_presence_of :name

  has_many :parameter_sub_categories, order: :name

  scope :by_name, order(:name)
end
