class DateRange
  attr_accessor :from_date_text
  attr_accessor :to_date_text
  attr_accessor :from_date
  attr_accessor :to_date
  attr_accessor :error

  def initialize(from_date_text, to_date_text, allow_all_blank=true)
    self.from_date_text = from_date_text
    self.to_date_text = to_date_text

    if (from_date_text.blank? && to_date_text.blank? && !allow_all_blank)
      self.error = "Please enter at least one date"
      return
    end

    self.from_date = parse_date(from_date_text)
    self.to_date = parse_date(to_date_text)

    check_from_date_is_before_to_date
  end

  def blank?
    self.from_date.nil? && self.to_date.nil?
  end

  def valid?
    self.error.nil?
  end

  def check_from_date_is_before_to_date
    if from_date && to_date
      if from_date > to_date
        self.error = "To date must be on or after from date"
      end
    end
  end

  def parse_date(text)
    if text.blank?
      return nil
    end

    begin
      Date.parse(text)
    rescue Exception
      self.error = "You entered an invalid date, please enter dates as yyyy-mm-dd"
      nil
    end
  end

end