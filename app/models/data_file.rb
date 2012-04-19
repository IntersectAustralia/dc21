require 'tempfile'

class DataFile < ActiveRecord::Base
  STATUS_UNKNOWN = 'UNKNOWN'
  STATUS_RAW = 'RAW'
  STATUS_CLEANSED = 'CLEANSED'
  STATUS_PROCESSED = 'PROCESSED'
  STATI = [STATUS_UNKNOWN, STATUS_RAW, STATUS_CLEANSED, STATUS_PROCESSED]
  STATUS_ERROR = 'ERROR'
  ALL_STATI = [STATUS_UNKNOWN, STATUS_RAW, STATUS_CLEANSED, STATUS_PROCESSED, STATUS_ERROR]

  belongs_to :created_by, :class_name => "User"
  has_many :column_details, :dependent => :destroy
  has_many :metadata_items, :dependent => :destroy
  has_and_belongs_to_many :tags

  validates_presence_of :filename
  validates_presence_of :path
  validates_presence_of :created_by_id
  validates_presence_of :file_processing_status
  validates_presence_of :experiment_id
  validates_length_of :file_processing_description, :maximum => 255
  validates_presence_of :start_time, :if => :end_time?
  validate :end_time_not_before_start_time

  scope :most_recent_first, order("created_at DESC")
# search scopes are using squeel - see http://erniemiller.org/projects/squeel/ for details of syntax
  scope :with_station_name_in, lambda { |station_names_array| includes(:metadata_items).merge(MetadataItem.for_key_with_value_in(MetadataKeys::STATION_NAME_KEY, station_names_array)) }
  scope :with_data_covering_date, lambda { |date| where { (start_time < (date + 1.day)) & (end_time >= (date)) } }
  scope :with_filename_containing, lambda { |name| where("data_files.filename ILIKE ?", "%#{name}%") }
  scope :with_description_containing, lambda { |name| where("data_files.file_processing_description ILIKE ?", "%#{name}%") }
  scope :with_status_in, lambda { |stati| where {file_processing_status.in stati} }
  #scope :with_any_of_these_tags, lambda { |tags| joins(:tags).where("data_files_tags.tag_id" => tags)}

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

  def self.with_any_of_these_tags(tags)
    data_file_ids = DataFile.unscoped.select("DISTINCT(data_files.id)").joins(:tags).where("data_files_tags.tag_id" => tags).collect(&:id)
    where(:id => data_file_ids)
  end

  def self.with_any_of_these_columns(column_names)
    data_file_ids = ColumnDetail.unscoped.select("DISTINCT(data_file_id)").where(:name => column_names).collect(&:data_file_id)
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


  def known_format?
    !self.format.nil?
  end

  def has_data_in_range?(from, to)
    return false unless known_format?
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

  def facility
    station_name_item = metadata_items.where(:key => MetadataKeys::STATION_NAME_KEY).first
    return nil unless station_name_item
    Facility.find_by_code(station_name_item.value)
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

  protected

  def with_filtered_data_in_date_range_in_temp_file(from_time, to_time, &block)
    # from_date and to_date are inclusive
    # block takes one argument, the Tempfile with the filtered data
    raise "unsupported format: #{self.format}" unless self.format == FileTypeDeterminer::TOA5
    file = Tempfile.new('filtered_datafile')
    begin
      delimiter = nil
      File.new(self.path).each_line.with_index do |line, idx|
        delimiter = Toa5Utilities.detect_delimiter(line) if idx == 0
        next unless idx > 3 # skip header lines

        time = Toa5Utilities.extract_time_from_data_line(line, delimiter)

        next if time < from_time
        break if time > to_time

        file.write(line)
      end
      file.seek 0
      block.call(file)
    ensure
      file.close
      file.unlink
    end
  end

  private

  def end_time_not_before_start_time
    return true unless start_time.present? && end_time.present?
    errors.add(:end_time, "cannot be before start time") unless self.start_time <= self.end_time
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

      candidate_overlap_data_file.with_filtered_data_in_date_range_in_temp_file(start_comparison_time, end_comparison_time) do |candidate_overlap_file|
        self.with_filtered_data_in_date_range_in_temp_file(start_comparison_time, end_comparison_time) do |my_overlap_file|
          FileUtils.identical? candidate_overlap_file, my_overlap_file
        end
      end
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

      candidate_overlap_data_file.with_filtered_data_in_date_range_in_temp_file(start_comparison_time, end_comparison_time) do |candidate_overlap_file|
        self.with_filtered_data_in_date_range_in_temp_file(start_comparison_time, end_comparison_time) do |my_overlap_file|
          !FileUtils.identical? candidate_overlap_file, my_overlap_file
        end
      end
    end

    exact_overlaps | start_time_overlaps | end_time_overlaps | total_overlaps | content_mismatch
  end


end
