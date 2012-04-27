# Wrapper class for PublishedCollection objects so we can generate RIF-CS from them.
# This defines the mapping from DC21 domain concepts to fields in the RIF-CS xml.
# This is used by the RIF-CS generator to actually output RIF-CS.

class PublishedCollectionRifCsWrapper < RifCsWrapper

  attr_accessor :options, :files, :date_range

  def initialize(collection_object, files, options)
    super(collection_object)
    self.options = options
    self.date_range = options[:date_range]
    self.files = files
  end

  def collection_type
    'dataset'
  end

  def group
    'University of Western Sydney'
  end

  def originating_source
    options[:root_url]
  end

  def key
    options[:collection_url]
  end

  def electronic_location
    options[:zip_url]
  end

  def submitter_name
    options[:submitter].full_name
  end

  def submitter_email
    options[:submitter].email
  end

  # returns an array of strings, each item being the text for a local subject
  def local_subjects
    experiments = files.collect(&:experiment)
    subjects = experiments.collect(&:subject).uniq.sort
    subjects.select { |s| !s.blank? }
  end

  def access_rights
    experiments = files.collect(&:experiment)
    experiments.collect(&:access_rights).uniq.sort
  end

  # returns an array of strings, each item being an FOR code in its PURL format
  def for_codes
    codes = files.collect { |f| f.experiment.experiment_for_codes }.flatten
    codes.collect(&:url).uniq.sort
  end

  # returns the start of the temporal coverage period as a date object
  # start is considered to be the later of either the earliest start date in the files OR the start of the date range being searched
  def start_date
    earliest_from_files = files.collect(&:start_time).compact.sort.first
    return nil unless earliest_from_files

    # beware of issues with timezones - we store the file start/end times as UTC (since we don't know the zone) - don't change this unless you understand it
    earliest_from_files_as_date = earliest_from_files.utc.to_date
    if date_range && date_range.from_date
      start_of_range = date_range.from_date
      start_of_range > earliest_from_files_as_date ? start_of_range : earliest_from_files_as_date
    else
      earliest_from_files_as_date
    end
  end

  # returns the end of the temporal coverage period as a date object
  # end is considered to be the earlier of either the latest end date in the files OR the end of the date range being searched
  def end_date
    latest_from_files = files.collect(&:end_time).compact.sort.last
    return nil unless latest_from_files

    # beware of issues with timezones - we store the file start/end times as UTC (since we don't know the zone) - don't change this unless you understand it
    latest_from_files_as_date = latest_from_files.utc.to_date
    if date_range && date_range.to_date
      end_of_range = date_range.to_date
      end_of_range < latest_from_files_as_date ? end_of_range : latest_from_files_as_date
    else
      latest_from_files_as_date
    end
  end

  # Returns an array of locations for the collection. Each element in the array is also an array, containing the point(s) for that specific location
  #TODO: this is a bit cumbersome, could be improved
  def locations
    facilities = files.collect { |f| f.experiment.facility }.uniq
    locations = []
    facilities.each do |f|
      locations << f.location unless f.location.empty?
    end
    locations
  end
end