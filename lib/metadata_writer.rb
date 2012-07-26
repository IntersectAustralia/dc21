class MetadataWriter

  def write_facility_metadata(facility, directory_path)
    file_path = File.join(directory_path, "#{facility.name.parameterize}.txt")
    File.open(file_path, 'w') do |file|
      file.puts "Name: #{facility.name}"
      file.puts "Code: #{facility.code}"
      file.puts "Description: #{facility.description}"
      file.puts "Location: #{facility.location}"
      file.puts "Primary Contact: #{facility.primary_contact.full_name} (#{facility.primary_contact.email})"
      file.puts "Persistent URL: #{facility_url(facility)}"
    end
    file_path
  end


  def write_experiment_metadata(experiment, directory_path)
    file_path = File.join(directory_path, "#{experiment.name.parameterize}.txt")
    File.open(file_path, 'w') do |file|
      file.puts "Parent: #{experiment.parent_name}"
      file.puts "Name: #{experiment.name}"
      # Description may be nil, but nil interpolates to empty string
      # We follow the same approach for all attributes that can be nil
      file.puts "Description: #{experiment.description}"
      file.puts "Start date: #{experiment.start_date.to_s(:date_only)}"
      file.puts "End date: #{experiment.end_date.try(:to_s, :date_only)}"
      file.puts "Subject: #{experiment.subject}"
      file.puts "Access Rights: #{experiment.access_rights}"
      file.puts "FOR codes: #{experiment.experiment_for_codes.map { |for_code| for_code.name }.join("\n")}"
      file.puts "Persistent URL: #{experiment_url(experiment)}"
      file.puts ""
      file.puts "Parameters"
      experiment.experiment_parameters.each do |param|
        file.puts ""
        file.puts "Category: #{param.parameter_category.name}"
        file.puts "Subcategory: #{param.parameter_sub_category.name}"
        file.puts "Modification: #{param.parameter_modification.name}"
        file.puts "Amount: #{param.amount}"
        file.puts "Units: #{param.parameter_unit.name}"
        file.puts "Comments: #{param.comments}"
      end

    end
    file_path
  end

  def write_data_file_metadata(datafile, directory_path)
    metadata_filename = File.basename(datafile.filename, '.*')
    file_path = File.join(directory_path, "#{metadata_filename}-metadata.txt")
    File.open(file_path, 'w') do |file|
      file.puts "Basic information"
      file.puts ""
      file.puts "Name: #{datafile.filename}"
      file.puts "Type: #{datafile.status_as_string}"
      file.puts "File format: #{datafile.format_for_display}"
      file.puts "Description: #{datafile.file_processing_description}"
      file.puts "Tags: #{datafile.tags.map { |tag| tag.name }.join(", ")}"
      file.puts "Experiment: #{datafile.experiment.name}"
      file.puts "Date added: #{datafile.created_at.to_s(:with_time)}"
      file.puts "Added by: #{datafile.created_by.full_name}"
      file.puts "Persistent URL: #{data_file_url(datafile)}"
      file.puts ""
      if datafile.known_format?
        file.puts "Information From The File"
        file.puts ""
        file.print "Start time: "
        file.print datafile.start_time.utc.to_s(:with_seconds) if datafile.start_time != nil
        file.puts ""
        file.print "End time: "
        file.print datafile.end_time.utc.to_s(:with_seconds) if datafile.end_time != nil
        file.puts
        display_interval = datafile.interval == nil ? "" : ActionController::Base.helpers.distance_of_time_in_words(datafile.interval)
        file.puts "Sample interval: #{display_interval}"
        datafile.metadata_items.each do |item|
          file.puts "#{item.key.humanize}: #{item.value}"
        end

        file.puts ""
        file.puts "Columns"
        file.puts ""
        datafile.column_details.each do |column_details|
          file.puts "Column: #{column_details.name}"
          file.print "Column Mapping: "
          ColumnMapping.all.each do |map|
            unless map.check_col_mapping(column_details.name).nil?
              file.print "#{map.name} "
            end
          end
          file.puts ""
          file.puts "Unit: #{column_details.unit}"
          file.puts "Measurement Type: #{column_details.data_type}"
          file.puts ""
        end
      end
    end
    file_path
  end

  private
  def facility_url(facility)
    Rails.application.routes.url_helpers.facility_url(facility, :host => host_url)
  end

  def experiment_url(experiment)
    Rails.application.routes.url_helpers.facility_experiment_url(experiment.facility, experiment, :host => host_url)
  end


  def data_file_url(data_file)
    Rails.application.routes.url_helpers.data_file_url(data_file, :host => host_url)
  end

  def host_url
    "localhost"
  end
end
