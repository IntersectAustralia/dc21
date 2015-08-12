class Package < DataFile

  validates_presence_of :title
  validates_length_of :title, :maximum => 10000

  PACKAGE_FORMAT = 'BAGIT'
  FILE_EXTENSION = '.zip'

  ACCESS_RIGHTS_OPEN = 'Open'
  ACCESS_RIGHTS_CONDITIONAL = 'Conditional'
  ACCESS_RIGHTS_RESTRICTED = 'Restricted'


  default_scope where(:format => PACKAGE_FORMAT, :file_processing_status => "PACKAGE")

  before_save :set_external_id

  def set_external_id
    if self.external_id.blank?
      prefix = APP_CONFIG['handle_prefix'] || "hiev"
      prefix = prefix[0..99]
      package_id = self.class.connection.select_value("SELECT nextval('package_id_seq')").to_i - 1
      self.update_attribute(:external_id, "#{prefix}_#{package_id}".strip)
      unless APP_CONFIG['hdl_handle_prefix'].nil?
        hdl = APP_CONFIG['hdl_handle_prefix'].gsub('${sequence_number}', package_id.to_s)
        self.update_attribute(:hdl_handle, hdl)
      end
    end
  end

  def self.create_package(params, date_params, current_user)
    reformat_time(params, date_params)
    datafile = Package.new
    datafile.filename = "#{params[:filename]}#{FILE_EXTENSION}" unless params[:filename].blank?
    datafile.format = PACKAGE_FORMAT
    datafile.path = create_temp_path(params[:filename])
    datafile.created_by = current_user
    datafile.start_time = params[:start_time]
    datafile.end_time = params[:end_time]
    datafile.file_processing_status = STATUS_PACKAGE
    datafile.file_processing_description = params[:file_processing_description]
    datafile.experiment_id = params[:experiment_id]
    datafile.published = false
    datafile.title = params[:title]
    datafile.transfer_status = RESQUE_QUEUED
    config = SystemConfiguration.instance
    datafile.language = config.language
    datafile.rights_statement = config.rights_statement
    datafile.physical_location = config.entity
    datafile.research_centre_name = config.research_centre_name
    datafile.access_rights_type = params[:access_rights_type]
    if datafile.access_rights_type == ACCESS_RIGHTS_OPEN
      datafile.access_rights_uri = config.open_access_rights_uri
      datafile.access_rights_text = config.open_access_rights_text
    elsif datafile.access_rights_type == ACCESS_RIGHTS_CONDITIONAL
      datafile.access_rights_uri = config.conditional_access_rights_uri
      datafile.access_rights_text = config.conditional_access_rights_text
    elsif datafile.access_rights_type == ACCESS_RIGHTS_RESTRICTED
      datafile.access_rights_uri = config.restricted_access_rights_uri
      datafile.access_rights_text = config.restricted_access_rights_text
    end
    datafile
  end

  def reformat_on_error(filename, tags, label_list, grant_number_list)
    self.filename = filename
    self.tag_ids = tags
    self.label_ids = label_list
    self.grant_number_ids = grant_number_list
  end

  def set_times(user)
    start_df = user.cart_items.earliest_start_time.first
    if start_df.nil?
      self.start_time = nil
    else
      self.start_time = start_df.start_time
    end

    end_df = user.cart_items.latest_end_time.first
    if end_df.nil?
      self.end_time = nil
    else
      self.end_time = end_df.end_time
    end
  end

  def set_metatdata
    config = SystemConfiguration.instance
    self.language = config.language
    self.rights_statement = config.rights_statement
    self.physical_location = config.entity
    self.research_centre_name = config.research_centre_name
  end

  private

  def self.create_temp_path(filename)
    File.join(APP_CONFIG['files_root'], "#{filename}#{FILE_EXTENSION}" )
  end

  def self.reformat_time(params, date_params)
    if !params[:start_time].blank? && !params[:end_time].blank?
      # From the API
      params[:start_time] = params[:start_time] << ' UTC'
      params[:end_time] = params[:end_time] << ' UTC'
      return
    end

    if date_params.nil?
      params.merge!(:start_time => '', :end_time => '')
    else
      start_time = parse_date_and_time(date_params[:start_time], date_params[:start_hr], date_params[:start_min], date_params[:start_sec])
      end_time = parse_date_and_time(date_params[:end_time], date_params[:end_hr], date_params[:end_min], date_params[:end_sec])
      params.merge!(:start_time => start_time, :end_time => end_time)
    end
  end

  def self.parse_date_and_time(date, hr, min, sec)
    return if date.blank?
    adjusted_date = date
    if hr.present? && min.present? && sec.present?
      adjusted_date << " " << hr << ":" << min << ":" << sec
    end
    return adjusted_date << "UTC"
  end
end
