class MetadataWriter

  def self.generate_metadata_for(data_files)
    experiments = data_files.map(&:experiment).uniq.delete_if { |exp| exp.nil? }
    facilities = experiments.map(&:facility).uniq

    HTML_METADATA_HAML_ENGINE.render(Object.new, :data_files => data_files, :experiments => experiments, :facilities => facilities, :metadata_url_helper => MetadataUrlHelper.new)
  end
end

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