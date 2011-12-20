class DataFile < ActiveRecord::Base

  serialize :metadata, Hash

  belongs_to :created_by, :class_name => "User"
  has_many :column_details
  has_many :metadata_items

  validates_presence_of :filename
  validates_presence_of :path
  validates_presence_of :created_by_id

  scope :most_recent_first, order("created_at DESC")

  def extension
    ext = File.extname(filename)[1..-1]
    ext ? ext.downcase : nil
  end

  def self.search_by_date(date)
    # search is using squeel - see ... for details of syntax
    where { (start_time < (date + 1.day)) & (end_time >= (date)) }
  end

  def add_metadata_item(key, value)
    self.metadata_items.create!(:key => key, :value => value)
  end

  def format_for_display
    self.format.nil? ? "Unknown" : self.format
  end

end
