require File.expand_path('../exceptions/template_error.rb', __FILE__)

class MetadataWriter
  def self.generate_metadata_for(data_files, pkg)
    experiments = data_files.map(&:experiment).uniq.delete_if { |exp| exp.nil? }
    facilities = experiments.map(&:facility).uniq

    metadata_engine = use_template_if_exists
    begin
      metadata_engine.render(Object.new, :data_files => data_files,
                             :package => pkg,
                             :config => SystemConfiguration.instance,
                             :experiments => experiments,
                             :facilities => facilities,
                             :metadata_helper => MetadataHelper.new(facilities))
    rescue SyntaxError => e
      raise TemplateError, "syntax error in external template file for HTML"
    rescue NameError => e
      raise TemplateError, "undefined variable in external template file for HTML"
    end
  end

  private

  # This will impact performance as it needs to check for changes
  def self.use_template_if_exists
    # Check if the actual configuration exists
    external_template_file = APP_CONFIG['readme_template_file']
    external_template_directory = APP_CONFIG['readme_template_directory']
    template_path = ""

    if external_template_file.blank? or external_template_directory.blank?
      template_path = File.join(Rails.root, APP_CONFIG['default_readme_template_file'])
    else
      Dir.mkdir(external_template_directory) unless Dir.exists? external_template_directory
      template_path = File.join(external_template_directory, external_template_file)
      unless File.exist? template_path
        template_path = File.join(Rails.root, APP_CONFIG['default_readme_template_file'])
      end
    end

    template = File.read(template_path)
    Haml::Engine.new(template)
  end
end

class MetadataHelper
  include ActionView::Helpers::NumberHelper

  def initialize(facilities)
    url_options = Rails.application.config.action_mailer.default_url_options
    host = url_options[:host]
    protocol = url_options[:protocol]
    port = url_options[:port]
    @host_details = {host: host, protocol: protocol, port: port}
    @facility_users = aggregate_facility_users(facilities)
  end

  def has_node_user_from_data_files(creator)
    @facility_users.include? creator
  end

  def software_version
    File.open('app/views/shared/_tag.html.haml').read
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
    number_to_human_size(number, :precision => 2).gsub(" ", "")
  end

  private

  def aggregate_facility_users(facilities)
    facility_user_nodes = []
    facilities.each do |facility|
      facility.aggregated_contacts.each do |contact|
        facility_user_nodes.push(contact) unless facility_user_nodes.include? contact
      end
    end
    facility_user_nodes
  end
end