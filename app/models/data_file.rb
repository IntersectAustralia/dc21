class DataFile < ActiveRecord::Base

  belongs_to :created_by, :class_name => "User"

  validates_presence_of :filename
  validates_presence_of :format
  validates_presence_of :path
#  validates_presence_of :created_by_id

  scope :most_recent_first, order("created_at DESC")

  def extension
    ext = File.extname(filename)[1..-1]
    ext ? ext.downcase : nil
  end
end
