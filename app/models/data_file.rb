require 'tempfile'

class DataFile < ActiveRecord::Base
  # raw and error are special status values that cannot be modified/removed
  # the rest come from a config file and can be customised per installation
  STATUS_RAW = 'RAW'
  STATUS_ERROR = 'ERROR'
  # stati for selection when uploading
  STATI = [STATUS_RAW] + APP_CONFIG['file_types']
  # cannot change to 'RAW' or 'ERROR' during editing
  STATI_FOR_EDIT = STATI - [STATUS_RAW]
  # for searching we include error as well
  ALL_STATI = STATI + [STATUS_ERROR]


  belongs_to :created_by, :class_name => "User"
  belongs_to :experiment
  has_many :column_details, :dependent => :destroy
  has_many :metadata_items, :dependent => :destroy
  has_and_belongs_to_many :tags

  before_validation :strip_whitespaces

  validates_presence_of :filename
  validates_uniqueness_of :filename
  validates_presence_of :path
  validates_presence_of :created_by_id
  validates_presence_of :file_processing_status
  validates_presence_of :experiment_id
  validates_length_of :file_processing_description, :maximum => 255
  validates_presence_of :start_time, :if => :end_time?, :message => "is required if End time specified"
  validate :end_time_not_before_start_time

  before_save :fill_end_time_if_blank

  scope :most_recent_first, order("created_at DESC")
  # search scopes are using squeel - see http://erniemiller.org/projects/squeel/ for details of syntax
  scope :with_station_name_in, lambda { |station_names_array| includes(:metadata_items).merge(MetadataItem.for_key_with_value_in(MetadataKeys::STATION_NAME_KEY, station_names_array)) }
  scope :with_data_covering_date, lambda { |date| where { (start_time < (date + 1.day)) & (end_time >= (date)) } }
  scope :with_filename_containing, lambda { |name| where("data_files.filename ILIKE ?", "%#{name}%") }
  scope :with_description_containing, lambda { |name| where("data_files.file_processing_description ILIKE ?", "%#{name}%") }
  scope :with_status_in, lambda { |stati| where { file_processing_status.in stati } }
  scope :with_uploader, lambda { |uploader| where("data_files.created_by_id" => uploader) }

  attr_accessor :messages

  def self.with_data_in_range(from, to)
    if (from && to)
      where { (start_time < (to + 1.day)) & (end_time >= from) }
    elsif from
      where { end_time >= from }
    else
      where { start_time < (to + 1.day) }
    end
  end

  def self.with_uploaded_date_in_range(from, to)
    if (from && to)
      where { (created_at < (to + 1.day)) & (created_at >= from) }
    elsif from
      where { created_at >= from }
    else
      where { created_at < (to + 1.day) }
    end
  end

  def self.with_any_of_these_tags(tags)
    data_file_ids = DataFile.unscoped.select("DISTINCT(data_files.id)").joins(:tags).where("data_files_tags.tag_id" => tags).collect(&:id)
    where(:id => data_file_ids)
  end

  def self.with_any_of_these_columns(column_names)
    data_file_ids = ColumnDetail.unscoped.select("DISTINCT(data_file_id)").where(:name => column_names).collect(&:data_file_id)
    where(:id => data_file_ids)
  end

  def self.with_experiment(experiment_names)
    data_file_ids = DataFile.unscoped.select("data_files.id").joins(:experiment).where("experiments.name" => experiment_names).collect(&:id)
    where(:id => data_file_ids)
  end

  def self.searchable_facilities
    existing_values = MetadataItem.select("DISTINCT(value)").where(:key => MetadataKeys::STATION_NAME_KEY).collect(&:value)
    code_to_name_hash = Hash[*Facility.find_all_by_code(existing_values).collect { |mi| [mi.code, mi.name] }.flatten]
    existing_values.each do |value|
      code_to_name_hash[value] = value unless code_to_name_hash[value]
    end
    code_to_name_hash.collect { |k, v| [k, v] }.sort { |a, b| a[1] <=> b[1] }
  end

  def self.searchable_column_names
    mapped = ColumnMapping.code_to_name_map

    mapped_codes = mapped.keys
    mapped_names = mapped.values

    existing_values = ColumnDetail.unscoped.select("DISTINCT(name)").collect(&:name)
    existing_values.delete_if { |name| mapped_codes.include?(name) }
    (mapped_names + existing_values).uniq.sort
  end

  def extension
    ext = File.extname(filename)[1..-1]
    ext ? ext.downcase : nil
  end

  def add_metadata_item(key, value)
    self.metadata_items.create!(:key => key, :value => value)
  end

  def format_for_display
    self.format.nil? ? "Unknown" : self.format
  end

  def start_time_is_not_nil?
    !self.start_time.nil?
  end

  def end_time_is_not_nil?
    !self.end_time.nil?
  end

  def known_format?
    !self.format.nil?
  end

  def is_raw_file?
    self.file_processing_status.eql? STATUS_RAW
  end

  def is_error_file?
    self.file_processing_status.eql? STATUS_ERROR
  end

  def has_data_in_range?(from, to)
    return false if self.start_time.nil?

    if (from && to)
      (self.start_time < (to + 1.day)) && (self.end_time >= from)
    elsif from
      self.end_time >= from
    else
      self.start_time < (to + 1.day)
    end
  end

  def cols_unmapped?
    self.column_details.each do |col|
      if col.find_by_code_uncased.nil?
        return true
      end
    end
    return false
  end

  def status_as_string
    self.file_processing_status.present? ? self.file_processing_status.upcase : "UNDEFINED"
  end

  def experiment_name
    return "Other" if experiment_id == -1
    return "" if experiment_id.nil?
    Experiment.find(experiment_id).name
  end

  def facility_name
    return "" if experiment_id.nil? || experiment_id == -1
    Experiment.find(experiment_id).facility.name
  end

  def add_message(type, message)
    self.messages ||= []
    self.messages << {:type => type, :message => message}
  end

  def rename_to(new_path, new_name)
    require 'fileutils'
    FileUtils.mv(path, new_path)
    self.path = new_path
    self.filename = new_name
    save!
  end

  def rename_file(old_filename, new_filename, path_dir)
    if new_filename != old_filename
      new_path = File.join(path_dir, new_filename)
      rename_to(new_path, new_filename)
    end
  end

  def categorise_overlap(new_file)
    #assumes if we've got here then new_file is from same station and table and is RAW+toa5, this just about dates/times
    #returns NONE, SAFE, UNSAFE

    # new file ends before I start
    return 'NONE' if new_file.end_time < self.start_time
    # new file starts after I end
    return 'NONE' if new_file.start_time > self.end_time

    # new file starts before or on my start, ends after or on my end - i.e. is identical or a superset and could be safe to replace me
    if new_file.start_time <= self.start_time && new_file.end_time >= self.end_time
      # check that the content actually matches
      return 'SAFE' if FileOverlapContentChecker.new(self, new_file).content_matches
    end

    # otherwise, must be unsafe
    'UNSAFE'
  end

  def raw_toa5_files_with_same_station_name_and_table_name
    station_name = metadata_items.find_by_key(MetadataKeys::STATION_NAME_KEY).try(:value)
    table_name = metadata_items.find_by_key(MetadataKeys::TABLE_NAME_KEY).try(:value)

    toa5_files = DataFile.where(:format => FileTypeDeterminer::TOA5, :file_processing_status => STATUS_RAW)
    toa5_files = DataFile.where(:id => (toa5_files - DataFile.where(:id => self.id)))

    by_table_name = toa5_files.joins(:metadata_items).where(:metadata_items => {:key => MetadataKeys::TABLE_NAME_KEY, :value => table_name})
    by_station_name = toa5_files.joins(:metadata_items).where(:metadata_items => {:key => MetadataKeys::STATION_NAME_KEY, :value => station_name})

    DataFile.where(:id => (by_table_name & by_station_name).map(&:id))
  end

  protected

  def entity_url(host_url)
    Rails.application.routes.url_helpers.data_file_url(self, :host => host_url)
  end

  def strip_whitespaces
    self.filename.strip! if self.filename
  end

  private

  def end_time_not_before_start_time
    return true unless start_time.present? && end_time.present?
    errors.add(:end_time, "cannot be before start time") unless self.start_time <= self.end_time
  end

  def fill_end_time_if_blank
    if start_time.present? && end_time.blank?
      self.end_time = self.start_time
    end
  end
end
