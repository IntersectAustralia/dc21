require 'uri'

class RelatedWebsite < ActiveRecord::Base

  validates_presence_of :url
  validates_uniqueness_of :url, :case_sensitive => false
  validates_length_of :url, :maximum => 80
  validates_format_of :url, :with => URI::regexp(%w(http https ftp)), :message => "%{value} is not a valid url"

  has_many :data_file_related_websites

  before_validation :remove_white_spaces
  before_validation :strip_single_quotes
  default_scope order(:url)

  def remove_white_spaces
    self.url = self.url.to_s.strip
  end

  def strip_single_quotes
    self.url = self.url.slice(1..-1) if self.url.start_with?("'")
    self.url = self.url.slice(0..-2) if self.url.ends_with?("'")
  end

end
