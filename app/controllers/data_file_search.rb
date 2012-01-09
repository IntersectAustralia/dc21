class DataFileSearch

  attr_accessor :search_params
  attr_accessor :error
  attr_accessor :date_range
  attr_accessor :facilities
  attr_accessor :variables


  def initialize(search_params)
    @search_params = search_params
    @search_params ||= {}

    self.date_range = DateRange.new(@search_params[:from_date], @search_params[:to_date], true)
    self.error = date_range.error

    self.facilities = @search_params[:facilities]
    self.facilities ||= []
    self.variables = @search_params[:variables]
    self.variables ||= []

    if !valid?
      self.date_range = DateRange.new(nil, nil, true)
    end
  end

  def showing_all?
    date_range.from_date.nil? && date_range.to_date.nil? && (facilities.nil? || facilities.empty?) && (variables.nil? || variables.empty?)
  end

  def valid?
    self.error.blank?
  end

  def do_search(relation)
    search_result = relation
    if date_range.from_date || date_range.to_date
      search_result = search_result.with_data_in_range(date_range.from_date, date_range.to_date)
    end
    unless facilities.nil? || facilities.empty?
      search_result = search_result.with_station_name_in(facilities)
    end
    unless variables.nil? || variables.empty?
      search_result = search_result.with_any_of_these_columns(variables)
    end
    search_result
  end

end
