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
  belongs_to :experiment
  has_many :column_details, :dependent => :destroy
  has_many :metadata_items, :dependent => :destroy
  has_many :cart_items
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
  before_save :set_file_size_if_nil

  scope :most_recent_first, order("created_at DESC")
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

  def check_for_bad_overlap
    station_item = metadata_items.find_by_key MetadataKeys::STATION_NAME_KEY
    table_item = metadata_items.find_by_key MetadataKeys::TABLE_NAME_KEY
    if station_item and table_item
      overlap = mismatched_overlap(station_item.value, table_item.value)

      if overlap.any?
        add_message(:error, 'File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with ' + overlap.map(&:filename).join(', '))
        self.file_processing_status = DataFile::STATUS_ERROR
        self.save!
        return true
      end

    end
    false
  end

  def add_message(type, message)
    self.messages ||= []
    self.messages << {:type => type, :message => message}
  end

  def destroy_safe_overlap
    station_item = metadata_items.find_by_key MetadataKeys::STATION_NAME_KEY
    table_item = metadata_items.find_by_key MetadataKeys::TABLE_NAME_KEY
    if station_item and table_item
      overlap = safe_overlap(station_item.value, table_item.value)

      unless overlap.empty?
        add_message(:info, "The file replaced one or more other files with similar data. Replaced files: #{overlap.collect(&:filename).join(", ")}")

        overlap_descriptions = overlap.map(&:file_processing_description)
        overlap.each { |df| df.destroy }
        self.file_processing_description = overlap_descriptions.join(', ') if file_processing_description.blank?
        save!
      end

      return overlap.collect(&:filename)
    end
    []
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


  def set_to_published
    self.published = true
    self.published_date = DateTime.now
    save!
  end

  protected

  def entity_url(host_url)
    Rails.application.routes.url_helpers.data_file_url(self, :host => host_url)
  end

  protected

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

  protected
  def set_file_size_if_nil
    self.file_size = 0 unless self.file_size
  end

  def candidate_overlaps(files)
    # filters given files for files which might be "overwritable"
    left_overlaps = files.where('start_time = ?', start_time)
    left_overlaps = left_overlaps.where('end_time < ?', end_time)

    middle_overlaps = files.where('start_time > ?', start_time)
    middle_overlaps = middle_overlaps.where('end_time < ?', end_time)

    right_overlaps = files.where('start_time > ?', start_time)
    right_overlaps = right_overlaps.where('end_time = ?', end_time)

    left_overlaps | right_overlaps | middle_overlaps
  end

  def relevant_overlap_files(station_name, table_name)
    toa5_files = DataFile.where(:format => FileTypeDeterminer::TOA5, :file_processing_status => STATUS_RAW)
    toa5_files = DataFile.where(:id => (toa5_files - DataFile.where(:id => self.id)))

    by_table_name = toa5_files.joins(:metadata_items).where(:metadata_items => {:key => MetadataKeys::TABLE_NAME_KEY, :value => table_name})
    by_station_name = toa5_files.joins(:metadata_items).where(:metadata_items => {:key => MetadataKeys::STATION_NAME_KEY, :value => station_name})

    toa5_files = DataFile.where(:id => (by_table_name & by_station_name).map(&:id))
  end

  def safe_overlap(station_name, table_name)
    return [] if self.format != FileTypeDeterminer::TOA5 or self.file_processing_status != STATUS_RAW

    toa5_files = relevant_overlap_files(station_name, table_name)

    candidate_overlaps = candidate_overlaps(toa5_files)


    candidate_overlaps.find_all do |candidate_overlap_data_file|
      start_comparison_time = [candidate_overlap_data_file.start_time, self.start_time].max
      end_comparison_time = [candidate_overlap_data_file.end_time, self.end_time].min

      temp_dir = Dir.mktmpdir

      candidate_overlap_file = Toa5Subsetter.extract_matching_rows_to(candidate_overlap_data_file, temp_dir, start_comparison_time, end_comparison_time, true)
      my_overlap_file = Toa5Subsetter.extract_matching_rows_to(self, temp_dir, start_comparison_time, end_comparison_time, true)

      FileUtils.identical? candidate_overlap_file, my_overlap_file
    end
  end

  def mismatched_overlap(station_name, table_name)
    # This method is intended to be called for files which aren't yet persisted
    # Thus, they will not have associated MetadataItem records
    # That is why they are listed as parameters here.
    # This method assumes TOA5 files all have start_times and end_times populated

    return [] if self.format != FileTypeDeterminer::TOA5 or self.file_processing_status != STATUS_RAW

    toa5_files = relevant_overlap_files(station_name, table_name)

    start_time_overlaps = toa5_files.where('start_time > ?', start_time)
    start_time_overlaps = start_time_overlaps.where('start_time <= ?', end_time)
    start_time_overlaps = start_time_overlaps.where('end_time > ?', end_time)

    total_overlaps = toa5_files.where('start_time < ?', start_time)
    total_overlaps = total_overlaps.where('end_time > ?', end_time)
    total_overlaps |= toa5_files.where('start_time = ?', start_time).where('end_time > ?', end_time)
    total_overlaps |= toa5_files.where('start_time < ?', start_time).where('end_time = ?', end_time)

    end_time_overlaps = toa5_files.where('start_time < ?', start_time)
    end_time_overlaps = end_time_overlaps.where('end_time < ?', end_time)
    end_time_overlaps = end_time_overlaps.where('end_time >= ?', start_time)

    exact_overlaps = toa5_files.where('start_time = ? and end_time = ?', start_time, end_time)

    candidate_overlaps = candidate_overlaps(toa5_files)

    content_mismatch = candidate_overlaps.find_all do |candidate_overlap_data_file|
      start_comparison_time = [candidate_overlap_data_file.start_time, self.start_time].max
      end_comparison_time = [candidate_overlap_data_file.end_time, self.end_time].min

      mismatch = false
      Dir.mktmpdir { |temp_dir|
        candidate_overlap_file = Toa5Subsetter.extract_matching_rows_to(candidate_overlap_data_file, temp_dir, start_comparison_time, end_comparison_time, true)
        my_overlap_file = Toa5Subsetter.extract_matching_rows_to(self, temp_dir, start_comparison_time, end_comparison_time, true)

        mismatch = !FileUtils.identical?(candidate_overlap_file, my_overlap_file)
      }
      mismatch
    end

    exact_overlaps | start_time_overlaps | end_time_overlaps | total_overlaps | content_mismatch
  end
end
