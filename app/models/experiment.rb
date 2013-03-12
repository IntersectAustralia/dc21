class Experiment < ActiveRecord::Base

  belongs_to :facility
  belongs_to :parent_experiment, :class_name => "Experiment"
  has_many :experiment_for_codes, :order => "name ASC"
  has_many :experiment_parameters

  validates_presence_of :name
  validates_presence_of :subject
  validates_presence_of :facility_id
  validates_presence_of :access_rights
  validates_length_of :name, :subject, {:maximum => 255}
  validates_length_of :description, :maximum => 8192

  # Work around to check invalid dates
  def self.validate_date(start_date, end_date)
    if end_date.present?
      validates :end_date, :date => {:message => 'must be a valid date'}
    end

    if start_date.present?
      validates :end_date, :date => {:after_or_equal_to => :start_date, :message => 'cannot be before start date' }
      validates :start_date, :date => {:message => 'must be a valid date'}
    else
      validates_presence_of :start_date
    end
  end

  def set_start_date(start_date)
    self.start_date = start_date
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
