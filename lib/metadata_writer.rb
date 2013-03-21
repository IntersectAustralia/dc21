class MetadataWriter
  def self.generate_metadata_for(data_files, pkg)
    experiments = data_files.map(&:experiment).uniq.delete_if { |exp| exp.nil? }
    facilities = experiments.map(&:facility).uniq

    metadata_engine = use_template_if_exists
    metadata_engine.render(Object.new, :data_files => data_files,
                                     :package => pkg,
                                     :experiments => experiments,
                                     :facilities => facilities,
                                     :metadata_helper => MetadataHelper.new)
  end

  private

  # This will impact performance as it needs to check for changes
  def self.use_template_if_exists
    # Check if the actual configuration exists
    external_template_file = APP_CONFIG['readme_template_file']
    template_path = ""

    if external_template_file.blank?
      template_path = File.join(Rails.root, "app/templates/file_set_metadata.html.haml")
    else
      template_path = File.join(Rails.root, external_template_file)
      unless File.exist? template_path
        template_path = File.join(Rails.root, "app/templates/file_set_metadata.html.haml")
      end
    end

    template = File.read(template_path)
    metadata_engine = Haml::Engine.new(template)
  end
end

class MetadataHelper
  include ActionView::Helpers::NumberHelper

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

  def data_file_download_url(data_file)
    Rails.application.routes.url_helpers.download_data_file_url(data_file, @host_details)
  end

  def split_or_truncate(description)
    unless description.blank?
      sentence = description.split('.')[0]
      sentence.length > 80 ? sentence.truncate(80) : sentence
    end
  end

  def readable_bytes(number)
    number_to_human_size(number, :precision => 2)
  end
end