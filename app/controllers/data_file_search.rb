class DataFileSearch

  attr_accessor :search_params
  attr_accessor :error
  attr_accessor :date_range
  attr_accessor :facilities
  attr_accessor :experiments
  attr_accessor :variables
  attr_accessor :variable_parents
  attr_accessor :filename
  attr_accessor :description
  attr_accessor :stati
  attr_accessor :tags
  attr_accessor :uploader_id
  attr_accessor :upload_date_range
  attr_accessor :published
  attr_accessor :unpublished
  attr_accessor :published_date
  attr_accessor :published_date_check

  def initialize(search_params)
    @search_params = search_params
    @search_params ||= {}

    self.date_range = DateRange.new(@search_params[:from_date], @search_params[:to_date], true)
    self.upload_date_range = DateRange.new(@search_params[:upload_from_date], @search_params[:upload_to_date], true)
    self.published_date_check = DateRange.new(@search_params[:published_date], "", true)
    handle_date_errors

    self.facilities = @search_params[:facilities]
    self.facilities ||= []
    self.experiments = @search_params[:experiments]
    self.experiments ||= []
    self.variables = @search_params[:variables]
    self.variables ||= []
    self.variable_parents = @search_params[:variable_parents]
    self.variable_parents ||= []
    self.stati = @search_params[:stati]
    self.stati ||= []
    self.tags = @search_params[:tags]
    self.tags ||= []
    self.published = @search_params[:published]
    self.published ||= []
    self.unpublished = @search_params[:unpublished]
    self.unpublished ||= []
    self.published_date = @search_params[:published_date] unless @search_params[:published_date].nil? or @search_params[:published_date].empty? or published_date_check.error
    self.uploader_id = @search_params[:uploader_id]
    self.filename = @search_params[:filename]
    self.description = @search_params[:description]

    if !valid?
      self.date_range = DateRange.new(nil, nil, true)
      self.upload_date_range = DateRange.new(nil, nil, true)
      self.published_date = nil
    end
  end

  def showing_all?
    date_range.from_date.nil? &&
        date_range.to_date.nil? &&
        facilities.empty? &&
        experiments.empty? &&
        variables.empty? &&
        stati.empty? &&
        tags.empty? &&
        filename.blank? &&
        description.blank? &&
        uploader_id.blank?
  end

  def valid?
    self.error.blank?
  end

  def handle_date_errors
    error_text = []
      if published_date_check.error
        error_text << "Published Date: #{published_date_check.error}"
      end
      if date_range.error
        error_text << "Date Range: #{date_range.error}"
      end
      if upload_date_range.error
        error_text << "Upload Date Range: #{upload_date_range.error}"
      end
      self.error = error_text.join(", ") unless error_text.empty?
  end

  def do_search(relation)

    search_result = relation
    if date_range.from_date || date_range.to_date
      search_result = search_result.with_data_in_range(date_range.from_date, date_range.to_date)
    end
    if upload_date_range.from_date || upload_date_range.to_date
      search_result = search_result.with_uploaded_date_in_range(upload_date_range.from_date, upload_date_range.to_date)
    end
    unless experiments.nil? || experiments.empty?
      search_result = search_result.with_experiment(experiments)
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
    unless uploader_id.nil? || uploader_id.empty?
      search_result = search_result.with_uploader(uploader_id)
    end
    unless published.nil? || published.empty?
      search_result = search_result.with_published
    end
    unless unpublished.nil? || unpublished.empty?
      search_result = search_result.with_unpublished
    end
    unless published_date.nil? or published_date.empty?
      date = Date.parse(published_date)
      search_result = search_result.with_published_date(date) unless date.nil?
    end
    search_result
  end

end
