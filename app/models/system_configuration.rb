class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class SystemConfiguration < ActiveRecord::Base

  acts_as_singleton
  validates_presence_of :level1, :level1_plural, :level2, :level2_plural

  validates :name, presence:true, length: {maximum: 20}
  validates :research_centre_name, presence:true, length: {maximum: 80}
  validates :entity, presence: true, length: {maximum: 80}

  validates :email, email:true
  validates :telephone_number, format: { with: /\A[+]?\d+\Z/, message: "is not a valid phone number"}
end
