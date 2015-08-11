class DataFileSearch

  attr_accessor :search_params
  attr_accessor :error
  attr_accessor :date_range
  attr_accessor :facilities
  attr_accessor :experiments
  attr_accessor :variables
  attr_accessor :variable_parents
  attr_accessor :file_id
  attr_accessor :stati
  attr_accessor :automation_stati
  attr_accessor :tags
  attr_accessor :labels
  attr_accessor :grant_numbers
  attr_accessor :related_websites
  attr_accessor :file_formats
  attr_accessor :uploader_id
  attr_accessor :upload_date_range
  attr_accessor :published
  attr_accessor :unpublished
  attr_accessor :published_date
  attr_accessor :published_date_check
  attr_accessor :searched_attributes
  attr_accessor :filename
  attr_accessor :description
  attr_accessor :id
  attr_accessor :filename_invalid
  attr_accessor :description_invalid
  attr_accessor :id_invalid

  def initialize(search_params)
    @search_params = search_params || {}

    self.date_range = DateRange.new(@search_params[:from_date], @search_params[:to_date], true)
    self.upload_date_range = DateRange.new(@search_params[:upload_from_date], @search_params[:upload_to_date], true)
    self.published_date_check = DateRange.new(@search_params[:published_date], "", true)

    self.facilities = @search_params[:facilities]
    self.facilities ||= @search_params[:org_level1] || []
    self.experiments = @search_params[:experiments]
    self.experiments ||= @search_params[:org_level2] || []
    self.experiments = Experiment.where(:facility_id => facilities).pluck(:id) if !facilities.blank? && experiments.blank?
    self.variables = @search_params[:variables] || []
    self.variable_parents = @search_params[:variable_parents]|| []
    self.stati = @search_params[:stati]|| []
    self.automation_stati = @search_params[:automation_stati] || []
    self.tags = @search_params[:tags]|| []
    self.labels = @search_params[:labels]|| []
    self.grant_numbers = @search_params[:grant_numbers]|| []
    self.related_websites = @search_params[:related_websites]|| []
    self.file_formats = @search_params[:file_formats] || []
    self.published = @search_params[:published]|| []
    self.unpublished = @search_params[:unpublished]|| []
    self.published_date = @search_params[:published_date] unless @search_params[:published_date].nil? or @search_params[:published_date].empty? or published_date_check.error
    self.uploader_id = @search_params[:uploader_id]
    self.filename = @search_params[:filename]
    self.description = @search_params[:description]
    self.file_id = @search_params[:file_id]
    self.id = @search_params[:id]

    error_text = []
    handle_date_errors(error_text)
    handle_regex_errors(error_text)
    self.error = error_text.join(", ") unless error_text.empty?

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
        automation_stati.empty? &&
        tags.empty? &&
        labels.empty? &&
        file_formats.empty? &&
        filename.blank? &&
        description.blank? &&
        file_id.blank? &&
        id.blank? &&
        uploader_id.blank? &&
        upload_date_range.from_date.nil? &&
        upload_date_range.to_date.nil?
  end

  def valid?
    self.error.blank?
  end

  def handle_date_errors(error_text)
    if published_date_check.error
      error_text << "Published Date: #{published_date_check.error}"
    end
    if date_range.error
      error_text << "Date Range: #{date_range.error}"
    end
    if upload_date_range.error
      error_text << "Upload Date Range: #{upload_date_range.error}"
    end
  end

  def handle_regex_errors(error_text)
    begin
     Regexp.try_convert(/#{filename}/)
    rescue RegexpError => e
      error_text << "Filename: #{e}"
      self.filename_invalid = true
    end

    begin
      Regexp.try_convert(/#{description}/)
    rescue RegexpError => e
      error_text << "Description: #{e}"
      self.description_invalid = true
    end

    begin
      Regexp.try_convert(/#{id}/)
    rescue RegexpError => e
      error_text << "ID: #{e}"
      self.id_invalid = true
    end
  end

  def do_search(relation)

    @config = SystemConfiguration.instance
    attrs_array = []
    search_result = relation
    if date_range.from_date || date_range.to_date
      search_result = search_result.with_data_in_range(date_range.from_date, date_range.to_date)
      attrs_array << "Date"
    end
    if upload_date_range.from_date || upload_date_range.to_date
      search_result = search_result.with_uploaded_date_in_range(upload_date_range.from_date, upload_date_range.to_date)
      attrs_array << "Date Added"
    end
    unless experiments.nil? || experiments.empty?
      search_result = search_result.with_experiment(experiments)
      attrs_array << @config.level2_plural
    end
    unless variables.nil? || variables.empty?
      search_result = search_result.with_any_of_these_columns(variables)
      attrs_array << "Columns"
    end
    unless stati.nil? || stati.empty?
      search_result = search_result.with_status_in(stati)
      attrs_array << "Type"
    end
    unless automation_stati.nil? || automation_stati.empty?
      search_result = search_result.with_transfer_status_in(automation_stati)
      attrs_array << "Status"
    end
    unless tags.nil? || tags.empty?
      search_result = search_result.with_any_of_these_tags(tags.collect { |tag| tag.to_i })
      attrs_array << "Tags"
    end
    unless labels.nil? || labels.empty?
      search_result = search_result.with_any_of_these_labels(labels)
      attrs_array << "Labels"
    end
    unless file_formats.nil? || file_formats.empty?
      search_result = search_result.with_any_of_these_file_formats(file_formats)
      attrs_array << "File Formats"
    end
    unless filename.blank? or filename_invalid
      search_result = search_result.with_filename_containing(filename)
      attrs_array << "Filename"
    end
    unless description.blank? or description_invalid
      search_result = search_result.with_description_containing(description)
      attrs_array << "Description"
    end
    unless file_id.blank?
      search_result = search_result.where(:id => file_id)
      attrs_array << "File ID"
    end
    unless id.blank? or id_invalid
      search_result = search_result.with_external_id(id)
      attrs_array << "ID"
    end
    unless uploader_id.nil? || uploader_id.empty?
      search_result = search_result.with_uploader(uploader_id)
      attrs_array << "Added By"
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

    self.searched_attributes = attrs_array.join(", ")
    search_result
  end

end
