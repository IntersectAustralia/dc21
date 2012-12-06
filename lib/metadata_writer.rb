class MetadataWriter

  def self.generate_metadata_for(data_files)
    experiments = data_files.map(&:experiment).uniq.delete_if { |exp| exp.nil? }
    facilities = experiments.map(&:facility).uniq

    HTML_METADATA_HAML_ENGINE.render(Object.new, :data_files => data_files, :experiments => experiments, :facilities => facilities, :metadata_url_helper => MetadataUrlHelper.new)
  end
end
# Now that we have HTML metadata, none of this is used, leaving here to help guide fully implementing HTML metadata
# Can be deleted once that is finished
#
#
#
#
#def write_data_file_metadata(datafile, directory_path)
#  base_filename = File.basename(datafile.filename, '.*')
#  extension = File.extname(datafile.filename)
#
#  metadata_filename = base_filename
#  metadata_filename << "-#{extension[1..-1]}" unless extension.blank?
#  metadata_filename << "-metadata.txt"
#
#  file_path = File.join(directory_path, metadata_filename)
#  File.open(file_path, 'w') do |file|

#    unless datafile.known_format?
#      write_line file, "Start time: #{datafile.start_time.utc.to_s(:with_seconds)}" if datafile.start_time
#      write_line file, "End time: #{datafile.end_time.utc.to_s(:with_seconds)}" if datafile.end_time
#    end

#    if datafile.known_format?
#      write_line file, "Information From The File"
#      write_line file, ""
#      start_time = datafile.start_time ? datafile.start_time.utc.to_s(:with_seconds) : ''
#      end_time = datafile.end_time ? datafile.end_time.utc.to_s(:with_seconds) : ''
#      write_line file, "Start time: #{start_time}"
#      write_line file, "End time: #{end_time}"
#      display_interval = datafile.interval == nil ? "" : ActionController::Base.helpers.distance_of_time_in_words(datafile.interval)
#      write_line file, "Sample interval: #{display_interval}"
#      datafile.metadata_items.order(:key).each do |item|
#        write_line file, "#{item.key.humanize}: #{item.value}"
#      end
#
#      write_line file, ""
#      write_line file, "Columns"
#      write_line file, ""
#      datafile.column_details.each do |column_details|
#        write_line file, "Column: #{column_details.name}"
#        file.print "Column Mapping: "
#        ColumnMapping.all.each do |map|
#          unless map.check_col_mapping(column_details.name).nil?
#            file.print "#{map.name} "
#          end
#        end
#        write_line file, ""
#        write_line file, "Unit: #{column_details.unit}"
#        write_line file, "Measurement Type: #{column_details.data_type}"
#        write_line file, ""
#      end
#    end
#  end
#  file_path
#end
#
#private
#
#def write_line(file, string)
#  #force windows line endings so that windows users can easily open the files in notepad
#  file.print string + "\r\n"
#end

class MetadataUrlHelper

  def initialize
    url_options = Rails.application.config.action_mailer.default_url_options
    host = url_options[:host]
    protocol = url_options[:protocol]
    port = url_options[:port]
    @host_details = {host: host, protocol: protocol, port: port}
  end

  def facility_url(facility)
    Rails.application.routes.url_helpers.facility_url(facility, @host_details)
  end

  def experiment_url(experiment)
    Rails.application.routes.url_helpers.facility_experiment_url(experiment.facility, experiment, @host_details)
  end


  def data_file_url(data_file)
    Rails.application.routes.url_helpers.data_file_url(data_file, @host_details)
  end

end