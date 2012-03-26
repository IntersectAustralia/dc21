class DataFileSearch

  attr_accessor :search_params
  attr_accessor :error
  attr_accessor :date_range
  attr_accessor :facilities
  attr_accessor :variables
  attr_accessor :variable_parents
  attr_accessor :filename
  attr_accessor :description
  attr_accessor :stati
  attr_accessor :tags


  def initialize(search_params)
    @search_params = search_params
    @search_params ||= {}

    self.date_range = DateRange.new(@search_params[:from_date], @search_params[:to_date], true)
    self.error = date_range.error

    self.facilities = @search_params[:facilities]
    self.facilities ||= []
    self.variables = @search_params[:variables]
    self.variables ||= []
    self.variable_parents = @search_params[:variable_parents]
    self.variable_parents ||= []
    self.stati = @search_params[:stati]
    self.stati ||= []
    self.tags = @search_params[:tags]
    self.tags ||= []

    self.filename = @search_params[:filename]
    self.description = @search_params[:description]

    if !valid?
      self.date_range = DateRange.new(nil, nil, true)
    end
  end

  def showing_all?
    date_range.from_date.nil? &&
        date_range.to_date.nil? &&
        facilities.empty? &&
        variables.empty? &&
        stati.empty? &&
        tags.empty? &&
        filename.blank? &&
        description.blank?

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
    unless stati.nil? || stati.empty?
      search_result = search_result.with_status_in(stati)
    end
    unless tags.nil? || tags.empty?
      search_result = search_result.with_any_of_these_tags(tags.collect { |tag| tag.to_i })
    end
    unless filename.blank?
      search_result = search_result.with_filename_containing(filename)
    end
    unless description.blank?
      search_result = search_result.with_description_containing(description)
    end
    search_result
  end

end
