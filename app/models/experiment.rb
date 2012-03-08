class Experiment < ActiveRecord::Base

  belongs_to :facility
  belongs_to :parent_experiment, :class_name => "Experiment"
  has_many :experiment_for_codes, :order => "name ASC"

  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :subject
  validates_presence_of :facility_id
  validates_presence_of :access_rights

  validate :validate_start_before_end

  def validate_start_before_end
    if end_date && start_date
      errors.add(:end_date, "cannot be before start date") if end_date < start_date
    end
  end


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
    experiment_for_codes.destroy_all
    return if codes.nil? || codes.empty?
    urls = []
    codes.each_value do |code_attrs|
      url = code_attrs["url"]
      unless urls.include?(url)
        experiment_for_codes.build(code_attrs)
        urls << url
      end
    end
  end

  def access_rights_description
    AccessRightsLookup.new.get_name(self.access_rights)
  end
end
