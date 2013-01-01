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
  attr_accessor :published_doi

  def initialize(search_params)
    @search_params = search_params
    @search_params ||= {}

    self.date_range = DateRange.new(@search_params[:from_date], @search_params[:to_date], true)
    self.upload_date_range = DateRange.new(@search_params[:upload_from_date], @search_params[:upload_to_date], true)
    #self.published_date = Date.parse(@search_params[:published_date].first) unless @search_params[:published_date].nil? or @search_params[:published_date].empty?

    self.error =
       # if published_date.error
       #   "Published Date: #{published_date.error}"
        if date_range.error && upload_date_range.error
          "Date Range: #{date_range.error}, Upload Date Range: #{upload_date_range.error}"
        else
          date_range.error || upload_date_range.error
        end


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

    self.uploader_id = @search_params[:uploader_id]
    self.filename = @search_params[:filename]
    self.description = @search_params[:description]

    if !valid?
      self.date_range = DateRange.new(nil, nil, true)
      self.upload_date_range = DateRange.new(nil, nil, true)
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
    #if published_date
    #  search_result = search_result.with_published_date(published_date)
    #end
#    unless published_doi.nil?
#      search_result = search_result.with_published_doi(published_doi)
#    end
    search_result
  end

end
