class SystemConfiguration < ActiveRecord::Base

  acts_as_singleton
  validates_presence_of :level1, :level1_plural, :level2, :level2_plural
  validates_length_of :level1, :level1_plural, :level2, :level2_plural, :maximum => 20
  validates_length_of :address1, :address2, :address3, :telephone_number, :urls, :maximum => 80
  validates_length_of :description, :maximum => 10000
  validates_length_of :auto_ocr_regex, :auto_sr_regex, :maximum => 1000

  validates :name, presence: true, length: {maximum: 20}
  validates :research_centre_name, presence: true, length: {maximum: 80}
  validates :entity, presence: true, length: {maximum: 80}
  validates :email, length: {maximum: 80}
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, allow_blank: true
  #validates :telephone_number, format: { with: /\A[+]?[\s\d]+\Z/, message: "is not a valid phone number"}

  validate :level2_cannot_equal_level1_fields
  validate :valid_regex

  def valid_regex
    begin
      Regexp.try_convert(/#{self.auto_ocr_regex}/)
    rescue RegexpError => e
      errors.add(:auto_ocr_regex, e.to_s)
    end

    begin
      Regexp.try_convert(/#{self.auto_sr_regex}/)
    rescue RegexpError => e
      errors.add(:auto_sr_regex, e.to_s)
    end
  end

  def level2_cannot_equal_level1_fields
    if self.level1.eql? self.level2
      errors.add(:level1, "singular cannot be the same as Level 2 singular")
    elsif self.level1.eql? self.level2_plural
      errors.add(:level1, "singular cannot be the same as Level 2 plural")
    end
    if self.level1_plural.eql? self.level2
      errors.add(:level1_plural, "cannot be the same as Level 2 singular")
    elsif self.level1_plural.eql? self.level2_plural
      errors.add(:level1_plural, "cannot be the same as Level 2 plural")
    end
  end

  def auto_ocr?(data_file, force=false)
    time = Time.now.to_s
    if self.auto_ocr_on_upload or force
      Rails.logger.info "Auto OCR on upload is checked at #{time}"
      if self.ocr_types.include?(data_file.format)
        Rails.logger.info "File type #{data_file.format} is supported (#{time})"
        if self.auto_ocr_regex.blank? or Regexp.new(self.auto_ocr_regex, Regexp::IGNORECASE).match(data_file.filename) or force
          Rails.logger.info "File #{data_file.filename} matches regular expression /#{self.auto_ocr_regex}/ (#{time})"
          Rails.logger.info "Auto OCR ResQue job triggered for file #{data_file.filename} at #{time}"
          return true
        else
          Rails.logger.info "File #{data_file.filename} did not conform to regular expression /#{self.auto_ocr_regex}/ (#{time})"
        end
      else
        Rails.logger.info "File type #{data_file.format} is not supported in #{self.ocr_types} (#{time})"
      end
    else
      Rails.logger.info "Auto OCR on upload is disabled (#{time})"
    end
    Rails.logger.info "Auto OCR ResQue job not triggered at #{time}"
    return false
  end

  def auto_sr?(data_file, force=false)
    time = Time.now.to_s
    if self.auto_sr_on_upload or force
      Rails.logger.info "Auto SR on upload is checked at #{time}"
      if self.sr_types.include?(data_file.format)
        Rails.logger.info "File type #{data_file.format} is supported (#{time})"
        if self.auto_sr_regex.blank? or Regexp.new(self.auto_sr_regex, Regexp::IGNORECASE).match(data_file.filename) or force
          Rails.logger.info "File #{data_file.filename} matches to regular expression /#{self.auto_sr_regex}/ (#{time})"
          Rails.logger.info "Auto SR ResQue job triggered for file #{data_file.filename} at #{time}"
          return true
        else
          Rails.logger.info "File #{data_file.filename} did not conform to regular expression /#{self.auto_sr_regex}/ (#{time})"
        end
      else
        Rails.logger.info "File type #{data_file.format} is not supported in #{self.sr_types} (#{time})"
      end
    else
      Rails.logger.info "Auto SR on upload is disabled (#{time})"
    end
    Rails.logger.info "Auto SR ResQue job not triggered at #{time}"
    return false
  end

  def mime_types
    EXTENSIONS.values.uniq
  end

  def supported_ocr_types=(array)
    self.ocr_types = array.sort.join(", ")
  end

  def supported_ocr_types
    self.ocr_types.split(", ").sort
  end

  def supported_sr_types=(array)
    self.sr_types = array.sort.join(", ")
  end

  def supported_sr_types
    self.sr_types.split(", ").sort
  end
end
