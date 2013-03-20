class Package < DataFile

  PACKAGE_FORMAT = 'BAGIT'
  FILE_EXTENSION = '.zip'

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
    datafile.tag_ids = params[:tags]
    datafile.external_id = pkg[:external_id]
    datafile
  end

  def reformat_on_error(filename)
    self.filename = filename
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
