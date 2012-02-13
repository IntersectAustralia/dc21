class Experiment < ActiveRecord::Base

  belongs_to :facility
  belongs_to :parent_experiment, :class_name => "Experiment"
  
  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :subject
  validates_presence_of :facility_id

  def name_with_prefix
    "Experiment - #{name}"
  end

  def parent_name
    if parent_experiment
      parent_experiment.name_with_prefix
    else
      "Facility - #{facility.name}"
    end
  end
end
