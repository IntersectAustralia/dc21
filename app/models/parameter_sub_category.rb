class ParameterSubCategory < ActiveRecord::Base
  belongs_to :parameter_category

  validates_presence_of :name
  validates_presence_of :parameter_category
end
