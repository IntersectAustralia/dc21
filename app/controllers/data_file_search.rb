class DataFileSearch

  attr_accessor :search_params
  attr_accessor :error
  attr_accessor :from_date
  attr_accessor :to_date
  attr_accessor :facilities


  def initialize(search_params)
    @search_params = search_params
    @search_params ||= {}

    self.from_date = parse_date(@search_params[:from_date])
    self.to_date = parse_date(@search_params[:to_date])
    self.facilities = @search_params[:facilities]
    self.facilities ||= []

    check_from_date_is_before_to_date

    if !valid?
      self.from_date = nil
      self.to_date = nil
    end
  end

  def showing_all?
    from_date.nil? && to_date.nil?
  end

  def status_message
    if from_date && to_date
      "Showing files containing data in the range #{from_date.to_s(:date_only)} to #{to_date.to_s(:date_only)}."
    elsif from_date
      "Showing files containing data for #{from_date.to_s(:date_only)} onwards."
    elsif to_date
      "Showing files containing data up to #{to_date.to_s(:date_only)}."
    else
      "Showing all files"
    end
  end


  def valid?
    self.error.blank?
  end

  def do_search(relation)
    search_result = relation
    if from_date || to_date
      search_result = search_result.with_data_in_range(self.from_date, self.to_date)
    end
    unless facilities.nil? || facilities.empty?
      search_result = search_result.with_station_name_in(self.facilities)
    end
    search_result
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
