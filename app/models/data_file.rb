class DataFile < ActiveRecord::Base

  serialize :metadata, Hash

  belongs_to :created_by, :class_name => "User"

  validates_presence_of :filename
  validates_presence_of :path
  validates_presence_of :created_by_id

  scope :most_recent_first, order("created_at DESC")

  def extension
    ext = File.extname(filename)[1..-1]
    ext ? ext.downcase : nil
  end

  def self.search_by_date(date)
    where { (start_time < (date + 1.day)) & (end_time >= (date)) }
  end

  def add_metadata_item(key, value)
    self.metadata ||= {}
    self.metadata[key] = value
  end

  def metadata_key_value_pairs
    #collect metadata items that are strings
    metadata.reject { |k, v| !v.is_a?(String) }
  end

  def format_for_display
    self.format.nil? ? "Unknown" : self.format
  end

end
