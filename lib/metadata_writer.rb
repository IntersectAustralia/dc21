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

  private
  def facility_url(facility)
    Rails.application.routes.url_helpers.facility_url(facility, :host => host_url)
  end

  def host_url
    "localhost"
  end
end
