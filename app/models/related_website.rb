class RelatedWebsite < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url, :case_sensitive => false
  # validates_length_of :url, maximum: 80
  has_many :data_file_related_websites

  before_validation :remove_white_spaces
  default_scope order(:url)

  def remove_white_spaces
    self.url = self.url.to_s.strip
  end

end
