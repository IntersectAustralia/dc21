class SystemConfiguration < ActiveRecord::Base

  acts_as_singleton
  validates_presence_of :level1, :level1_plural, :level2, :level2_plural
  validates_length_of :level1, :level1_plural, :level2, :level2_plural, :maximum=>20
  validates_length_of :address1, :address2, :address3, :telephone_number, :urls, :maximum=>80
  validates_length_of :description, :maximum=>10000

  validates :name, presence:true, length: {maximum: 20}
  validates :research_centre_name, presence:true, length: {maximum: 80}
  validates :entity, presence: true, length: {maximum: 80}
  validates :email, length: {maximum: 80}
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, allow_blank: true
  #validates :telephone_number, format: { with: /\A[+]?[\s\d]+\Z/, message: "is not a valid phone number"}

  validate :level2_cannot_equal_level1_fields

  def level2_cannot_equal_level1_fields
    if self.level1 != '' && self.level1 == self.level1_plural
      errors.add(:level1_plural, "cannot be the same as Level 1 singular")
    end

    if self.level2 != '' && self.level2 == self.level2_plural
      errors.add(:level2_plural, "cannot be the same as Level 2 singular")
    end

    if self.level1 == self.level2 || self.level1 == self.level2_plural
      errors.add(:level1, "singular cannot be the same as Level 2 singular or plural")
    elsif self.level1_plural == self.level2 || self.level1_plural == self.level2_plural
      errors.add(:level1_plural, "cannot be the same as Level 2 singular or plural")
    end
  end

end
