require 'tempfile'

class DataFile < ActiveRecord::Base
  # raw and error are special status values that cannot be modified/removed
  # the rest come from a config file and can be customised per installation
  STATUS_RAW = 'RAW'
  STATUS_ERROR = 'ERROR'
  STATUS_PACKAGE = 'PACKAGE'
  # stati for selection when uploading
  STATI = [STATUS_RAW] + APP_CONFIG['file_types']
  # cannot change to 'RAW' or 'ERROR' during editing
  STATI_FOR_EDIT = STATI - [STATUS_RAW]
  # for searching we include error as well
  ALL_STATI = [STATUS_PACKAGE] + STATI + [STATUS_ERROR]

  belongs_to :created_by, :class_name => "User"
  belongs_to :published_by, :class_name => "User"
  belongs_to :experiment
  has_many :column_details, :dependent => :destroy
  has_many :metadata_items, :dependent => :destroy
  has_many :cart_items, :dependent => :destroy
  has_and_belongs_to_many :tags

  before_validation :strip_whitespaces
  before_validation :truncate_file_processing_description

  validates_presence_of :filename
  validates_uniqueness_of :filename
  validates_presence_of :path
  validates_presence_of :created_by_id
  validates_presence_of :file_processing_status
  validates_presence_of :experiment_id
  validates_length_of :file_processing_description, :maximum => 10.kilobytes
  validates_presence_of :start_time, :if => :end_time?, :message => "is required if End time specified"
  validates_datetime :start_time, :allow_blank => true, :invalid_datetime_message => "must be a valid time"
  validates_datetime :end_time, :on_or_after => :start_time, :allow_blank => true,
                     :on_or_after_message => "cannot be before start time",
                     :invalid_datetime_message => "must be a valid time"

  before_save :fill_end_time_if_blank
  before_save :set_file_size_if_nil

  scope :most_recent_first, order("created_at DESC")
  scope :earliest_start_time, order("start_time ASC")
  scope :latest_end_time, order("end_time DESC")
  # search scopes are using squeel - see http://erniemiller.org/projects/squeel/ for details of syntax
  scope :with_station_name_in, lambda { |station_names_array| includes(:metadata_items).merge(MetadataItem.for_key_with_value_in(MetadataKeys::STATION_NAME_KEY, station_names_array)) }
  scope :with_data_covering_date, lambda { |date| where { (start_time < (date + 1.day)) & (end_time >= (date)) } }
  scope :with_filename_containing, lambda { |name| where("data_files.filename ILIKE ?", "%#{name}%") }
  scope :with_description_containing, lambda { |name| where("data_files.file_processing_description ILIKE ?", "%#{name}%") }
  scope :with_status_in, lambda { |stati| where { file_processing_status.in stati } }
  scope :with_uploader, lambda { |uploader| where("data_files.created_by_id" => uploader) }

  attr_accessor :messages, :url

  def as_json(options = {})
    super(options).merge(:url => url)
  end

  def is_published?
    published | false
  end

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

  def self.with_experiment(experiment_ids)
    where(:experiment_id => experiment_ids)
  end

  def self.with_published
    where{(file_processing_status != 'PACKAGE') | (published)}
  end

  def self.with_unpublished
    where{(file_processing_status != 'PACKAGE') | (published == false)}
  end

  def self.with_published_date(date)

    where {(file_processing_status != 'PACKAGE') | (published_date >= date.midnight) & (published_date < (date + 1).midnight)}
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

  def is_package?
    self.file_processing_status.eql? STATUS_PACKAGE
  end

  def is_toa5?
    self.format.eql?(FileTypeDeterminer::TOA5)
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
      if col.get_mapped_name.nil?
        return true
      end
    end
    return false
  end

  def experiment
    # we don't use an association because of the special behaviour with using -1 for "Other"
    return nil if experiment_id == -1 || experiment_id.nil?
    Experiment.find(experiment_id)
  end

  def experiment_name
    return "Other" if experiment_id == -1
    return "" if experiment_id.nil?
    Experiment.find(experiment_id).name
  end

  def facility
    return nil if experiment_id.nil? || experiment_id == -1
    Experiment.find(experiment_id).facility
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


  def set_to_published(current_user)
    self.published = true
    self.published_date = DateTime.now
    self.published_by_id = current_user.id
    save!
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

  protected

  def strip_whitespaces
    self.filename.strip! if self.filename
  end

  def truncate_file_processing_description
    if file_processing_description.length > 10.kilobytes
      self.file_processing_description = file_processing_description.truncate(10.kilobytes)
    end if file_processing_description.present?
  end

  private

  def fill_end_time_if_blank
    if start_time.present? && end_time.blank?
      self.end_time = self.start_time
    end
  end

  protected
  def set_file_size_if_nil
    self.file_size = 0 unless self.file_size
  end
end
