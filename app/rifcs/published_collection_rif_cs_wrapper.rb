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

  # returns the start of the temporal coverage period as a datetime object
  # start is considered to be the later of either the earliest start date in the files OR the start of the date range being searched
  def start_time
    earliest_from_files = files.collect(&:start_time).compact.sort.first
    return nil unless earliest_from_files

    # beware of issues with timezones - we store the file start/end times as UTC (since we don't know the zone) - don't change this unless you understand it
    earliest_from_files_as_dt = earliest_from_files.utc.to_datetime
    if date_range && date_range.from_date
      start_of_range = date_range.from_date.to_datetime
      start_of_range > earliest_from_files_as_dt ? start_of_range : earliest_from_files_as_dt
    else
      earliest_from_files_as_dt
    end
  end

  # returns the end of the temporal coverage period as a datetime object
  # end is considered to be the earlier of either the latest end date in the files OR the end of the date range being searched
  def end_time
    latest_from_files = files.collect(&:end_time).compact.sort.last

    return nil unless latest_from_files

    # beware of issues with timezones - we store the file start/end times as UTC (since we don't know the zone) - don't change this unless you understand it
    latest_from_files_as_dt = latest_from_files.utc.to_datetime
    if date_range && date_range.to_date
      end_of_range = date_range.to_date.to_datetime
      end_of_range < latest_from_files_as_dt ? end_of_range : latest_from_files_as_dt
    else
      latest_from_files_as_dt
    end
  end

end