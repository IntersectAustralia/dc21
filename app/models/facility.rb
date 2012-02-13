class Facility < ActiveRecord::Base

  validates :name, :code,  :presence => true,
                           :uniqueness => {:case_sensitive => false},
                           :length   => { :maximum => 50 }

  before_validation :remove_white_spaces

  default_scope :order => 'name ASC'

  has_many :column_details
  has_many :experiments, :order => 'name'


  def experiments_excluding_me(experiment)
    exps = Array.new(self.experiments)
    exps.delete(experiment)
    exps
  end

  private

  def remove_white_spaces
    self.name = self.name.to_s.strip
    self.code = self.code.to_s.strip
  end

end
