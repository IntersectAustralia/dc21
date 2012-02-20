class Facility < ActiveRecord::Base

  #Associations
  has_many :column_details
  has_many :experiments, :order => 'name'

  has_one :primary_contactable, :class_name => "FacilityContact", :conditions => {:primary => true}, :dependent => :destroy
  has_many :contactables, :class_name => "FacilityContact", :conditions => {:primary => false}, :dependent => :destroy

  has_one :primary_contact,
          :through => :primary_contactable,
          :class_name => 'User',
          :source => :user

  has_many :contacts,
           :through => :contactables,
           :class_name => 'User',
           :source => :user

  #accepts_nested_attributes_for :primary_contactable
  accepts_nested_attributes_for :primary_contact
  accepts_nested_attributes_for :contactables
  accepts_nested_attributes_for :contacts

  #Hooks
  before_validation :pigeonhole_location
  before_validation :remove_white_spaces
  after_validation :sanitise_location

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

  #validates_presence_of :primary_contact

  #Scopes
  default_scope :order => 'name ASC'


  #Methods
  def experiments_excluding_me(experiment)
    exps = Array.new(self.experiments)
    exps.delete(experiment)
    exps
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

  private

  def remove_white_spaces
    self.name = self.name.to_s.strip
    self.code = self.code.to_s.strip
  end

  def swap_ab_ll
    #Simple method, but will be used multiple times
    self.a_lat, self.b_lat = b_lat, a_lat
    self.a_long, self.b_long = b_long, a_long
  end

  def pigeonhole_location
    if self.a_lat.blank? && self.a_long.blank?
      swap_ab_ll
    end
  end

  def sanitise_location
    #This will come in handy:
    #http://stackoverflow.com/questions/2855189/sort-latitude-and-longitude-coordinates-into-clockwise-ordered-quadrilateral

    #Do we have a point or a rectangle?

    # Make sure top-left point is the top left point

  end
end
