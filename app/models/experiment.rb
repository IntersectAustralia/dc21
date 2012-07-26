class Experiment < ActiveRecord::Base

  belongs_to :facility
  belongs_to :parent_experiment, :class_name => "Experiment"
  has_many :experiment_for_codes, :order => "name ASC"
  has_many :experiment_parameters

  validates_presence_of :name
  validates_presence_of :start_date
  validates_presence_of :subject
  validates_presence_of :facility_id
  validates_presence_of :access_rights

  validates_length_of :name, :subject, {:maximum => 255}
  validates_length_of :description, :maximum => 8192

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

  def write_metadata_to_file(directory_path, host_url)
    file_path = File.join(directory_path, "#{name.parameterize}.txt")
    File.open(file_path, 'w') do |file|
      file.puts "Parent: #{parent_name}"
      file.puts "Name: #{name}"
      # Description may be nil, but nil interpolates to empty string
      # We follow the same approach for all attributes that can be nil
      file.puts "Description: #{description}"
      file.puts "Start date: #{start_date.to_s(:date_only)}"
      file.puts "End date: #{end_date.try(:to_s, :date_only)}"
      file.puts "Subject: #{subject}"
      file.puts "Access Rights: #{access_rights}"
      file.puts "FOR codes: #{experiment_for_codes.map { |for_code| for_code.name }.join("\n")}"
      file.puts "Persistent URL: #{entity_url(host_url)}"
      file.puts ""
      file.puts "Parameters"
      experiment_parameters.each do |param|
        file.puts ""
        file.puts "Category: #{param.parameter_category.name}"
        file.puts "Subcategory: #{param.parameter_sub_category.name}"
        file.puts "Modification: #{param.parameter_modification.name}"
        file.puts "Amount: #{param.amount}"
        file.puts "Units: #{param.parameter_unit.name}"
        file.puts "Comments: #{param.comments}"
      end

    end
    file_path
  end

  private 
  def entity_url(host_url)
    Rails.application.routes.url_helpers.facility_experiment_url(facility, self, :host => host_url)
  end
end
