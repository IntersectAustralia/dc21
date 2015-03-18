require 'tempfile'
require 'digest/md5'

class DataFile < ActiveRecord::Base
  # raw and error are special status values that cannot be modified/removed
  # the rest come from a config file and can be customised per installation
  STATUS_RAW = 'RAW'
  STATUS_ERROR = 'ERROR'
  STATUS_PACKAGE = 'PACKAGE'

  RESQUE_COMPLETE = 'COMPLETE'
  RESQUE_FAILED = 'FAILED'
  RESQUE_WORKING = 'WORKING'
  RESQUE_QUEUED = 'QUEUED'

  # stati for selection when uploading
  STATI = [STATUS_RAW] + APP_CONFIG['file_types']
  # cannot change to 'RAW' or 'ERROR' during editing
  STATI_FOR_EDIT = STATI - [STATUS_RAW]
  # for searching we include error as well
  ALL_STATI = [STATUS_PACKAGE] + STATI + [STATUS_ERROR]
  # for searching auto processing jobs
  AUTOMATION_STATI = [RESQUE_COMPLETE, RESQUE_FAILED, RESQUE_WORKING, RESQUE_QUEUED]

  ACCESS_PUBLIC = 'Public'
  ACCESS_PRIVATE = 'Private'


  has_many :parent_child_relationships,
           :class_name => "DataFileRelationship",
           :foreign_key => :child_id,
           :dependent => :destroy
  has_many :parents,
           :through => :parent_child_relationships,
           :source => :parent,
           :conditions => proc  { "parent_id <> child_id" }

  has_many :child_parent_relationships,
           :class_name => "DataFileRelationship",
           :foreign_key => :parent_id,
           :dependent => :destroy
  has_many :children,
           :through => :child_parent_relationships,
           :source => :child,
           :conditions => proc  { "child_id <> parent_id" }

  has_many :datafile_accesses, :uniq => true
  has_many :access_groups, :through => :datafile_accesses, :uniq => true

  belongs_to :created_by, :class_name => "User"
  belongs_to :published_by, :class_name => "User"
  belongs_to :experiment
  has_many :column_details, :dependent => :destroy
  has_many :metadata_items, :dependent => :destroy
  has_and_belongs_to_many :users

  has_and_belongs_to_many :tags, :uniq => true

  has_many :data_file_labels, :uniq => true
  has_many :labels, :through => :data_file_labels, :uniq => true

  attr_accessible :filename, :format, :created_at, :updated_at, :start_time, :end_time, :interval, :file_processing_status, :file_processing_description, :experiment_id, :file_size, :external_id, :title, :uuid, :parent_ids, :child_ids, :label_list, :tag_ids, :access, :access_to_all_institutional_users, :access_to_user_groups, :access_groups

  before_validation :strip_whitespaces
  before_validation :truncate_file_processing_description

  validates_presence_of :filename
  validates_uniqueness_of :filename
  validates_length_of :filename, :maximum => 255 - APP_CONFIG['files_root'].length

  validates_uniqueness_of :external_id, :allow_blank => true, :allow_nil => true,
                          :message => Proc.new { |error, attributes|
                            "'#{attributes[:value]}' is already being used by #{DataFile.find_by_external_id(attributes[:value]).filename}."
                          }

  validates_length_of :external_id, :maximum => 1000

  validates_presence_of :path

  validate :private_access_check

  validates_length_of :path, :maximum => 260
  validates_presence_of :created_by_id
  validates_presence_of :file_processing_status
  validates_presence_of :experiment_id
  validates_length_of :file_processing_description, :maximum => 10.kilobytes
  validates_presence_of :start_time, :if => :end_time?, :message => "is required if End time specified"
  validates_format_of :filename, :with => /^[^\/\\\?\*:|"<>]+$/, :message => %(cannot contain any of the following characters: / \\ ? * : | < > "), :allow_blank => true
  validates_datetime :start_time, :allow_blank => true, :invalid_datetime_message => "must be a valid time"
  validates_datetime :end_time, :on_or_after => :start_time, :allow_blank => true,
                     :on_or_after_message => "cannot be before start time",
                     :invalid_datetime_message => "must be a valid time"

  before_save :fill_end_time_if_blank
  before_save :set_file_size_if_nil

  scope :completed_items, where("transfer_status in (?, ?) OR transfer_status IS NULL OR uuid IS NULL", RESQUE_COMPLETE, RESQUE_FAILED)
  scope :count_unadded_items, where("transfer_status not in (?, ?)", RESQUE_COMPLETE, RESQUE_FAILED)
  scope :most_recent_first, order("created_at DESC")
  scope :most_recent_first_and_completed_items, order("created_at DESC").where("transfer_status = ? OR uuid IS NULL", RESQUE_COMPLETE)
  scope :earliest_start_time, order("start_time ASC").where("start_time IS NOT NULL")
  scope :latest_end_time, order("end_time DESC").where("end_time IS NOT NULL")
  # search scopes are using squeel - see http://erniemiller.org/projects/squeel/ for details of syntax
  scope :with_station_name_in, lambda { |station_names_array| includes(:metadata_items).merge(MetadataItem.for_key_with_value_in(MetadataKeys::STATION_NAME_KEY, station_names_array)) }
  scope :with_data_covering_date, lambda { |date| where { (start_time < (date + 1.day)) & (end_time >= (date)) } }
  scope :with_filename_containing, lambda { |name| where("data_files.filename ~* ?", name) }
  scope :with_description_containing, lambda { |desc| where("data_files.file_processing_description ~* ?", desc) }
  scope :with_status_in, lambda { |stati| where { file_processing_status.in stati } }
  scope :with_transfer_status_in, lambda { |automation_stati| where { transfer_status.in automation_stati } }
  scope :with_uploader, lambda { |uploader| where("data_files.created_by_id" => uploader) }
  scope :with_external_id, lambda { |ext_id| where("data_files.external_id ~* ?", ext_id) }
  scope :search_display_fields, joins(:created_by).joins(:experiment => :facility).select('data_files.id, data_files.filename, data_files.created_at, data_files.file_size, data_files.file_processing_status, experiments.name as experiment_name, users.email as uploader_email, data_files.access, data_files.access_to_all_institutional_users, data_files.access_to_user_groups, data_files.created_by_id')
  scope :relationship_fields, select([:id, 'filename as text', 'experiment_id as exp_id'])

  attr_accessor :messages, :url


  def private_access_check
    if self.access == ACCESS_PUBLIC
      if access_to_all_institutional_users? or access_to_user_groups?
        errors.add(:access, "Private Access Options cannot be set when Access is Public")
      end
    end
  end

  def uploader_email
    created_by.present? ? created_by.email : ""
  end

  def as_json(options = {})
    super(options).merge(:url => url)
  end

  def is_published?
    published | false
  end

  def access_group_list_display
    self.access_groups.find_all_by_status(true).collect {|ag| ag.name}.join(", ")
  end

  def label_list
    self.labels.pluck(:name).join("|")
  end

  def label_list_display
    self.labels.pluck(:name).join(", ")
  end

  def label_list=(new_value)
    label_names = new_value.split(/\|\s*/)
    self.labels = label_names.map { |name| Label.find_or_create_by_name(name) }
  end

  def modifiable?
    self.processed_by_resque? ? (transfer_status.eql? RESQUE_COMPLETE or transfer_status.eql? RESQUE_FAILED) : true
  end

  def mark_as_queued
    self.transfer_status = RESQUE_QUEUED
    self.save!
  end

  def mark_as_complete
    self.transfer_status = RESQUE_COMPLETE
    self.save!
  end

  def mark_as_working
    self.transfer_status = RESQUE_WORKING
    self.save!
  end

  def mark_as_failed
    self.transfer_status = RESQUE_FAILED
    self.save!
  end

  def zip_progress
    digest_filename = Digest::MD5.hexdigest(self.filename)
    path = "#{File.join(APP_CONFIG['files_root'], "#{digest_filename}.tmp")}"
    if File.exist?(path)
      zip_file = File.open(path, 'r')
      zip_file.size
    else
      0
    end
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
    data_file_ids = DataFile.unscoped.joins(:tags).where("data_files_tags.tag_id" => tags).pluck(:id).uniq
    where(:id => data_file_ids)
  end

  def self.with_any_of_these_labels(label_params)
    data_file_ids = DataFile.unscoped.joins(:labels).where { labels.name >> label_params }.pluck(:id).uniq
    where(:id => data_file_ids)
  end

  def self.with_any_of_these_file_formats(file_formats)
    data_file_ids = DataFile.unscoped.where(:format => file_formats).pluck(:id)
    where(:id => data_file_ids)
  end

  def self.with_any_of_these_columns(column_names)
    data_file_ids = ColumnDetail.unscoped.where(:name => column_names).pluck(:data_file_id).uniq
    where(:id => data_file_ids)
  end

  def self.with_experiment(experiment_ids)
    where(:experiment_id => experiment_ids)
  end

  def self.with_published
    where { (file_processing_status != 'PACKAGE') | (published) }
  end

  def self.with_unpublished
    where { (file_processing_status != 'PACKAGE') | (published == false) }
  end

  def self.with_published_date(date)

    where { (file_processing_status != 'PACKAGE') | (published_date >= date.midnight) & (published_date < (date + 1).midnight) }
  end

  def self.searchable_column_names
    mapped = ColumnMapping.code_to_name_map

    mapped_codes = mapped.keys
    mapped_names = mapped.values

    existing_values = ColumnDetail.unscoped.pluck(:name).uniq
    existing_values.delete_if { |name| mapped_codes.include?(name) }
    (mapped_names + existing_values).uniq.sort
  end

  def self.id_already_exist?(id)
    return DataFile.find_by_external_id(id) ? true : false
  end

  def extension
    ext = File.extname(filename)[1..-1]
    ext ? ext.downcase : nil
  end

  def add_metadata_item(key, value)
    self.metadata_items.create!(:key => key, :value => value)
  end

  def start_time_is_not_nil?
    !self.start_time.nil?
  end

  def end_time_is_not_nil?
    !self.end_time.nil?
  end

  def time_parsable?
    self.is_package? || self.is_toa5? || self.is_exif_image?
  end

  def is_raw_file?
    self.file_processing_status.eql? STATUS_RAW
  end

  def is_package?
    self.format.eql?(FileTypeDeterminer::BAGIT)
  end

  def processed_by_resque?
    self.uuid.present?
  end

  def is_netcdf?
    self.format.eql?(FileTypeDeterminer::NETCDF)
  end

  def is_toa5?
    self.format.eql?(FileTypeDeterminer::TOA5)
  end

  def is_ncml?
    self.format.eql?(FileTypeDeterminer::NCML)
  end

  def is_exif_image?
    ['image/jpeg', 'image/pjpeg', 'image/tiff', 'image/x-tiff'].include? self.format
  end

  def is_error_file?
    self.file_processing_status.eql? STATUS_ERROR
  end

  def show_columns?
    return (is_toa5? or is_netcdf? or is_ncml?)
  end

  def show_information_from_file?
    return (is_toa5? or is_exif_image? or is_netcdf? or is_ncml?)
  end

  def is_authorised_for_access_by?(current_user)
    if current_user.role.name == "Administrator" || self.created_by == current_user || self.access == DataFile::ACCESS_PUBLIC
      return true
    end

    if self.access == DataFile::ACCESS_PRIVATE
      if self.access_to_all_institutional_users && current_user.role.name == "Institutional User"
        return true
      elsif self.access_to_user_groups && !(current_user.access_groups.find_all_by_status(true) & self.access_groups.find_all_by_status(true)).empty?
        return true
      end
    end

    return false
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

  def experiment_name
    experiment.name
  end

  def facility
    experiment.facility
  end

  def facility_name
    experiment.facility.name
  end

  def facility_id
    experiment.facility_id
  end

  def ocr_supported?
    SystemConfiguration.instance.ocr_types.present? && SystemConfiguration.instance.supported_ocr_types.include?(format)
  end

  def sr_supported?
    SystemConfiguration.instance.sr_types.present? && SystemConfiguration.instance.supported_sr_types.include?(format)
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


  def location_link()
    return nil if not is_ncml? or metadata_items.empty?
    return metadata_items.find_by_key("location").value
  end

  def categorise_overlap(new_file)
    #assumes if we've got here then new_file is from same station and table and is RAW+toa5, this just about dates/times
    #returns NONE, SAFE, UNSAFE

    # new file ends before I start
    return 'NONE' if new_file.end_time < self.start_time
    # new file starts after I end
    return 'NONE' if new_file.start_time > self.end_time

    # new file starts before or on my start, ends after or on my end - i.e. is identical or a superset and could be safe to replace me
    if new_file.start_time <= self.start_time && new_file.end_time >= self.end_time and FileOverlapContentChecker.new(self, new_file).content_matches
      # check that the content actually matches
      return 'SAFE'
    end
    # otherwise, must be unsafe
    'UNSAFE'
  end

  def raw_toa5_files_with_same_station_name_and_table_name
    station_name = metadata_items.find_by_key(MetadataKeys::STATION_NAME_KEY).try(:value)
    table_name = metadata_items.find_by_key(MetadataKeys::TABLE_NAME_KEY).try(:value)

    toa5_files = DataFile.where("format = ? AND file_processing_status = ? AND data_files.id != ?", FileTypeDeterminer::TOA5, STATUS_RAW, self.id)

    by_table_name = toa5_files.joins(:metadata_items).where(:metadata_items => {:key => MetadataKeys::TABLE_NAME_KEY, :value => table_name})
    by_station_name = toa5_files.joins(:metadata_items).where(:metadata_items => {:key => MetadataKeys::STATION_NAME_KEY, :value => station_name})

    # DataFile.order(:created_at).where(:id => (by_table_name & by_station_name).map(&:id))
    DataFile.order(:created_at).from("(#{by_table_name.to_sql} INTERSECT #{by_station_name.to_sql}) as data_files")
  end

  protected

  def entity_url(host_url)
    Rails.application.routes.url_helpers.data_file_url(self, :host => host_url)
  end

  protected

  def strip_whitespaces
    self.filename.strip! if self.filename
    self.external_id.squish! if self.external_id
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
