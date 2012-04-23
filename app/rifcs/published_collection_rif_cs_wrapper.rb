# Wrapper class for PublishedCollection objects so we can generate RIF-CS from them.
# This defines the mapping from DC21 domain concepts to fields in the RIF-CS xml.
# This is used by the RIF-CS generator to actually output RIF-CS.

class PublishedCollectionRifCsWrapper < RifCsWrapper

  attr_accessor :root_url, :collection_url, :files

  def initialize(collection_object, files, options)
    super(collection_object)
    self.root_url = options[:root_url]
    self.collection_url = options[:collection_url]
    self.files = files
  end

  def collection_type
    'dataset'
  end

  def group
    'University of Western Sydney'
  end

  def originating_source
    root_url
  end

  def key
    collection_url
  end

  def local_subjects
    # returns an array of strings, being the text for each local subject
    experiments = files.collect { |f| f.experiment }
    subjects = experiments.collect(&:subject).uniq.sort
    subjects.select { |s| !s.blank? }
  end


end