class ExperimentParameter < ActiveRecord::Base
  belongs_to :experiment
  belongs_to :parameter_category
  belongs_to :parameter_sub_category
  belongs_to :parameter_modification
  belongs_to :parameter_unit

  validates_presence_of :experiment
  validates_presence_of :parameter_category
  validates_presence_of :parameter_sub_category
  validates_presence_of :parameter_modification
  validates_numericality_of :amount, :allow_blank => true
  validates_length_of :comments, :maximum => 255

  scope :in_order, joins(:parameter_category, :parameter_sub_category, :parameter_modification).order('parameter_categories.name, parameter_sub_categories.name, parameter_modifications.name')

  def parameter_unit_name
    parameter_unit ? parameter_unit.name : ""
  end
end
