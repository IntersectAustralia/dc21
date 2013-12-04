class Label < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
  has_many :data_file_labels


  before_validation :remove_white_spaces
  default_scope order(:name)

  def remove_white_spaces
    self.name = self.name.to_s.strip
  end
end