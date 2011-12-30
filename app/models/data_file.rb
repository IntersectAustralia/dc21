class DataFile < ActiveRecord::Base

  serialize :metadata, Hash

  belongs_to :created_by, :class_name => "User"
  has_many :column_details
  has_many :metadata_items

  validates_presence_of :filename
  validates_presence_of :path
  validates_presence_of :created_by_id

  scope :most_recent_first, order("created_at DESC")
  # search scopes are using squeel - see http://erniemiller.org/projects/squeel/ for details of syntax
  scope :with_station_name_in, lambda { |station_names_array| includes(:metadata_items).merge(MetadataItem.for_key_with_value_in(MetadataKeys::STATION_NAME_KEY, station_names_array)) }
  scope :with_data_covering_date, lambda { |date| where { (start_time < (date + 1.day)) & (end_time >= (date)) } }

  def self.with_data_in_range(from, to)
    if (from && to)
      where { (start_time < (to + 1.day)) & (end_time >= from) }
    elsif from
      where { end_time >= from }
    else
      where { start_time < (to + 1.day) }
    end
  end

  def self.with_any_of_these_columns(column_names)
    raw_column_names = ColumnMapping.map_names_to_codes(column_names)
    data_file_ids = ColumnDetail.unscoped.select("DISTINCT(data_file_id)").where(:name => raw_column_names).collect(&:data_file_id)
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

end
