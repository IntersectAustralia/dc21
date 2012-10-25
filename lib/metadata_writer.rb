class MetadataWriter

  def initialize(data_files, directory_path)
    @data_files = data_files
    @directory_path = directory_path
  end

  def generate_metadata
    experiments = @data_files.map(&:experiment).uniq.delete_if { |exp| exp == nil }
    facilities = experiments.map(&:facility).uniq

    files = []

    @data_files.each do |data_file|
      files << write_data_file_metadata(data_file, @directory_path)
    end

    experiments.each do |experiment|
      files << write_experiment_metadata(experiment, @directory_path)
    end

    facilities.each do |facility|
      files << write_facility_metadata(facility, @directory_path)
    end
    files
  end

  def write_facility_metadata(facility, directory_path)
    file_path = File.join(directory_path, "#{facility.name.parameterize}.txt")
    # open file in binary mode so we can control line endings
    File.open(file_path, 'wb') do |file|
      write_line file, "Name: #{facility.name}"
      write_line file, "Code: #{facility.code}"
      write_line file, "Description: #{facility.description}"
      write_line file, "Location: #{facility.location}"
      primary_contact = facility.primary_contact ? "#{facility.primary_contact.full_name} (#{facility.primary_contact.email})" : ""
      write_line file, "Primary Contact: #{primary_contact}"
      write_line file, "Persistent URL: #{facility_url(facility)}"
    end
    file_path
  end


  def write_experiment_metadata(experiment, directory_path)
    file_path = File.join(directory_path, "#{experiment.name.parameterize}.txt")
    File.open(file_path, 'w') do |file|
      write_line file, "Parent: #{experiment.parent_name}"
      write_line file, "Name: #{experiment.name}"
      # Description may be nil, but nil interpolates to empty string
      # We follow the same approach for all attributes that can be nil
      write_line file, "Description: #{experiment.description}"
      write_line file, "Start date: #{experiment.start_date.to_s(:date_only)}"
      write_line file, "End date: #{experiment.end_date.try(:to_s, :date_only)}"
      write_line file, "Subject: #{experiment.subject}"
      write_line file, "Access Rights: #{experiment.access_rights}"
      write_line file, "FOR codes: #{experiment.experiment_for_codes.map { |for_code| for_code.name }.join("\n")}"
      write_line file, "Persistent URL: #{experiment_url(experiment)}"
      write_line file, ""
      write_line file, "Parameters"
      experiment.experiment_parameters.each do |param|
        write_line file, ""
        write_line file, "Category: #{param.parameter_category.name}"
        write_line file, "Subcategory: #{param.parameter_sub_category.name}"
        write_line file, "Modification: #{param.parameter_modification.name}"
        write_line file, "Amount: #{param.amount}"
        write_line file, "Units: #{param.parameter_unit ? param.parameter_unit.name : ""}"
        write_line file, "Comments: #{param.comments}"
      end

    end
    file_path
  end

  def write_data_file_metadata(datafile, directory_path)
    base_filename = File.basename(datafile.filename, '.*')
    extension = File.extname(datafile.filename)

    metadata_filename = base_filename
    metadata_filename << "-#{extension[1..-1]}" unless extension.blank?
    metadata_filename << "-metadata.txt"

    file_path = File.join(directory_path, metadata_filename)
    File.open(file_path, 'w') do |file|
      write_line file, "Basic information"
      write_line file, ""
      write_line file, "Name: #{datafile.filename}"
      write_line file, "Type: #{datafile.status_as_string}"
      write_line file, "File format: #{datafile.format_for_display}"
      write_line file, "Description: #{datafile.file_processing_description}"
      write_line file, "Tags: #{datafile.tags.map { |tag| tag.name }.join(", ")}"
      write_line file, "Experiment: #{datafile.experiment_name}"
      write_line file, "Facility: #{datafile.facility_name}"
      write_line file, "Date added: #{datafile.created_at.to_s(:with_time)}"
      write_line file, "Added by: #{datafile.created_by.full_name}"
      unless datafile.known_format?
        write_line file, "Start time: #{datafile.start_time.utc.to_s(:with_seconds)}" if datafile.start_time
        write_line file, "End time: #{datafile.end_time.utc.to_s(:with_seconds)}" if datafile.end_time
      end
      write_line file, "Persistent URL: #{data_file_url(datafile)}"
      write_line file, ""
      if datafile.known_format?
        write_line file, "Information From The File"
        write_line file, ""
        start_time = datafile.start_time ? datafile.start_time.utc.to_s(:with_seconds) : ''
        end_time = datafile.end_time ? datafile.end_time.utc.to_s(:with_seconds) : ''
        write_line file, "Start time: #{start_time}"
        write_line file, "End time: #{end_time}"
        display_interval = datafile.interval == nil ? "" : ActionController::Base.helpers.distance_of_time_in_words(datafile.interval)
        write_line file, "Sample interval: #{display_interval}"
        datafile.metadata_items.order(:key).each do |item|
          write_line file, "#{item.key.humanize}: #{item.value}"
        end

        write_line file, ""
        write_line file, "Columns"
        write_line file, ""
        datafile.column_details.each do |column_details|
          write_line file, "Column: #{column_details.name}"
          file.print "Column Mapping: "
          ColumnMapping.all.each do |map|
            unless map.check_col_mapping(column_details.name).nil?
              file.print "#{map.name} "
            end
          end
          write_line file, ""
          write_line file, "Unit: #{column_details.unit}"
          write_line file, "Measurement Type: #{column_details.data_type}"
          write_line file, ""
        end
      end
    end
    file_path
  end

  private
  def facility_url(facility)
    Rails.application.routes.url_helpers.facility_url(facility, host_details)
  end

  def experiment_url(experiment)
    Rails.application.routes.url_helpers.facility_experiment_url(experiment.facility, experiment, host_details)
  end


  def data_file_url(data_file)
    Rails.application.routes.url_helpers.data_file_url(data_file, host_details)
  end

  def host_details
    url_options = Rails.application.config.action_mailer.default_url_options
    host = url_options[:host]
    protocol = url_options[:protocol]
    port = url_options[:port]
    { host: host, protocol: protocol, port: port}
  end

  def write_line(file, string)
    #force windows line endings so that windows users can easily open the files in notepad
    file.print string + "\r\n"
  end
end
