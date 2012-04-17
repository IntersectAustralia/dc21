# Wrapper class for PublishedCollection objects so we can generate RIF-CS from them.
# This defines the mapping from DC21 domain concepts to fields in the RIF-CS xml.
# This is used by the RIF-CS generator to actually output RIF-CS.

class PublishedCollectionRifCsWrapper < RifCsWrapper

  def collection_type
    'dataset'
  end

  def group
    'University of Western Sydney'
  end

  def originating_source
    'TODO'
  end

  def key
    'TODO'
    #Rails.application.routes.url_helpers.published_collection_url(published_collection)
  end


end