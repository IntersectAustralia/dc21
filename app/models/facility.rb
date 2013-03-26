class Facility < ActiveRecord::Base

  #Associations
  has_many :experiments, :order => 'name'
  has_many :aggregated_contactables, :class_name => "FacilityContact"
  has_one :primary_contactable, :class_name => "FacilityContact", :conditions => {:primary => true}, :dependent => :destroy
  has_many :contactables, :class_name => "FacilityContact", :conditions => {:primary => false}, :dependent => :destroy
  

  has_one :primary_contact,
          :through => :primary_contactable,
          :class_name => 'User',
          :source => :user

  has_many :contacts,
           :through => :contactables,
           :class_name => 'User',
           :source => :user,
           :order => 'users.last_name, users.first_name'

  accepts_nested_attributes_for :primary_contact
  accepts_nested_attributes_for :aggregated_contactables
  accepts_nested_attributes_for :contacts

  #Hooks
  before_validation :pigeonhole_location
  before_validation :remove_white_spaces

  #Validations
  validates :name, :code, :presence => true,
            :uniqueness => {:case_sensitive => false},
            :length => {:maximum => 50}


  validates_inclusion_of :a_lat, :in => -90..90, :allow_blank => true
  validates_inclusion_of :a_long, :in => -180..180, :allow_blank => true
  validates_inclusion_of :b_lat, :in => -90..90, :allow_blank => true
  validates_inclusion_of :b_long, :in => -180..180, :allow_blank => true

  validates_presence_of :a_lat, :if => :a_long?
  validates_presence_of :a_long, :if => :a_lat?
  validates_presence_of :b_lat, :if => :b_long?
  validates_presence_of :b_long, :if => :b_lat?

  validates_numericality_of :a_lat, :allow_blank => true
  validates_numericality_of :a_long, :allow_blank => true
  validates_numericality_of :b_lat, :allow_blank => true
  validates_numericality_of :b_long, :allow_blank => true

  validates_presence_of :primary_contact
  validates_length_of :description, :maximum => 10.kilobytes

  before_validation :truncate_description

  #Scopes
  default_scope :order => 'name ASC'


  #Methods
  def experiments_excluding_me(experiment)
    exps = Array.new(self.experiments)
    exps.delete(experiment)
    exps
  end

  def rdfa_location
    "#{a_lat}, #{a_long}, #{b_lat}, #{b_long}"
  end

  #If we have exactly one complete point
  def location
    if (a_lat && a_long) && !(b_lat || b_long)
      "#{a_lat} , #{a_long}"
    end
  end

  #If we have both points
  def loc_tl
    if (a_lat && a_long) && (b_lat && b_long)
      "#{a_lat} , #{a_long}"
    end
  end

  #If we have both points
  def loc_br
    if (a_lat && a_long) && (b_lat && b_long)
      "#{b_lat} , #{b_long}"
    end
  end

  # Returns an array of points for this facility. There will always be either zero, one or two points. One is a point, two is a rectangle.
  def location_as_points
    points = []
    if a_lat && a_long
      points << {:lat => a_lat, :long => a_long}
    end
    if b_lat && b_long
      points << {:lat => b_lat, :long => b_long}
    end
    points
  end

  private

  def truncate_description
    if description.length > 10.kilobytes
      self.description = description.truncate(10.kilobytes)
    end if description.present?
  end

  def entity_url(host_url)
    Rails.application.routes.url_helpers.facility_url(self, :host => host_url)
  end
  
  def remove_white_spaces
    self.name = self.name.to_s.strip
    self.code = self.code.to_s.strip
  end

  def pigeonhole_location
    if self.a_lat.blank? && self.a_long.blank?
      # if they've filled in b but not a, switch the b values into a
      self.a_lat, self.b_lat = b_lat, a_lat
      self.a_long, self.b_long = b_long, a_long
    end
  end

end
