class Experiment < ActiveRecord::Base

  belongs_to :facility
  belongs_to :parent_experiment, :class_name => "Experiment"
  has_many :experiment_for_codes, :order => "name ASC"
  
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

  def set_for_codes(codes)
    return if codes.nil? || codes.empty?
    codes.each_value do |code_attrs|
      experiment_for_codes.build(code_attrs)
    end

  end
end
