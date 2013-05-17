class Experiment < ActiveRecord::Base

  belongs_to :facility
  belongs_to :parent_experiment, :class_name => "Experiment"
  has_many :experiment_for_codes, :order => "name ASC"
  has_many :experiment_parameters

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :subject
  validates_presence_of :facility_id
  validates_presence_of :access_rights
  validates_presence_of :start_date
  validates_length_of :name, :subject, {:maximum => 255}
  validates_length_of :description, :maximum => 10.kilobytes

  before_validation :truncate_description

  validates_datetime :start_date, :allow_blank => true, :invalid_datetime_message => "must be a valid date"
  validates_datetime :end_date, :on_or_after => :start_date, :allow_blank => true,
                     :on_or_after_message => "cannot be before start date",
                     :invalid_datetime_message => "must be a valid date"

  # Validation of presence is triggered when date is invalid - rails returns nil so we filter out redundant messages
  def filter_errors
    if errors.messages[:start_date].size > 1
      errors.messages[:start_date].delete_at(errors.messages[:start_date].index("can't be blank"))
    end unless errors.messages[:start_date].nil?
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

  private

  def truncate_description
    if description.length > 10.kilobytes
      self.description = description.truncate(10.kilobytes)
    end if description.present?
  end


end
