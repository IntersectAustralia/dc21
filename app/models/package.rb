class Package < DataFile

  validates_presence_of :title
  validates_length_of :title, :maximum => 10000

  PACKAGE_FORMAT = 'BAGIT'
  FILE_EXTENSION = '.zip'

  default_scope where(:format => PACKAGE_FORMAT, :file_processing_status => "PACKAGE")

  before_save :set_external_id

  def set_external_id
    if self.external_id.blank?
      prefix = APP_CONFIG['hiev_handle_prefix'] || "hiev"
      prefix = prefix[0..99]
      package_id = self.class.connection.select_value("SELECT nextval('package_id_seq')").to_i - 1
      self.update_attribute(:external_id, "#{prefix}_#{package_id}".strip)
    end
  end

  def self.create_package(params, current_user)
    pkg = params[:package]
    reformat_time params
    datafile = Package.new
    datafile.filename = "#{pkg[:filename]}#{FILE_EXTENSION}" unless pkg[:filename].blank?
    datafile.format = PACKAGE_FORMAT
    datafile.path = create_temp_path(pkg[:filename])
    datafile.created_by = current_user
    datafile.start_time = pkg[:start_time]
    datafile.end_time = pkg[:end_time]
    datafile.file_processing_status = STATUS_PACKAGE
    datafile.file_processing_description = pkg[:file_processing_description]
    datafile.experiment_id = pkg[:experiment_id]
    datafile.published = false
    datafile.title = pkg[:title]
    datafile.label_list = pkg[:label_list]
    datafile.transfer_status = RESQUE_QUEUED
    datafile
  end

  def reformat_on_error(params)
    self.filename = params[:package][:filename]
    self.tag_ids = params[:tags]
    self.label_ids = params[:label_list]
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

  private

  def self.create_temp_path(filename)
    File.join(APP_CONFIG['files_root'], "#{filename}#{FILE_EXTENSION}" )
  end

  def self.reformat_time(params)
    if params[:date].nil?
      params[:package].merge!(:start_time => '', :end_time => '')
    else
      attrs = params[:date]
      start_time = parse_date_and_time(attrs[:start_time], attrs[:start_hr], attrs[:start_min], attrs[:start_sec])
      end_time = parse_date_and_time(attrs[:end_time], attrs[:end_hr], attrs[:end_min], attrs[:end_sec])
      params[:package].merge!(:start_time => start_time, :end_time => end_time)
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
