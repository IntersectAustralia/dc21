require 'builder'
require 'open-uri'
require 'nokogiri'
require 'open_uri_redirections'

# This class builds the RIF-CS for a collection, delegating to a wrapper object to find the necessary values.
# The idea is that this can be reused across projects, and that the project-specific details of what goes into
# the rifcs are encoded in the wrapper class. Create your own wrapper by subclassing RifCsWrapper. This is a work
# in progress and will likely need a bit of work to make it flexible enough to handle various different project needs.

class RifCsGenerator

  attr_accessor :wrapper_object, :xml

  def initialize(wrapper_object, target)
    self.wrapper_object = wrapper_object
    self.xml = Builder::XmlMarkup.new :target => target, :indent => 2
  end

  def build_rif_cs
    xml.instruct!
    xml.registryObjects(:xmlns => 'http://ands.org.au/standards/rif-cs/registryObjects',
                        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                        'xsi:schemaLocation' => 'http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/1.6/schema/registryObjects.xsd') do
      xml.registryObject group: wrapper_object.group do
        xml.key wrapper_object.key
        xml.originatingSource wrapper_object.originating_source
        xml.collection type: wrapper_object.collection_type do
          xml.name type: 'primary' do
            xml.namePart wrapper_object.title, {'xml:lang' => wrapper_object.language}
          end
          xml.name type: 'alternative' do
            xml.namePart wrapper_object.filename
          end

          xml.location do
            xml.address do
              xml.electronic type: 'url', target: 'directDownload' do
                xml.value wrapper_object.electronic_location
                xml.title wrapper_object.electronic_landing_page_title
                xml.byteSize wrapper_object.byte_size
                xml.notes wrapper_object.electronic_address_notes
              end
              xml.physical do
                xml.addressPart wrapper_object.physical_address, type: 'text'
              end
            end
          end

          wrapper_object.local_subjects.each do |subject|
            xml.subject subject, {'type' => 'local', 'xml:lang' => wrapper_object.language}
          end

          wrapper_object.for_codes.each do |for_code|
            xml.subject for_code, {type: 'anzsrc-for', 'xml:lang' => wrapper_object.language}
          end

          unless wrapper_object.file_processing_description.blank?
            xml.description wrapper_object.file_processing_description, {type: 'full', 'xml:lang' => wrapper_object.language}
          end

          xml.rights do
            xml.rightsStatement wrapper_object.rights_statement
            xml.accessRights wrapper_object.access_rights_text, {type: wrapper_object.access_rights_type, rightsUri: wrapper_object.access_rights_uri}
            xml.licence type: wrapper_object.license_type, rightsUri: wrapper_object.license_uri
          end

          xml.identifier wrapper_object.identifier_uri, {type: 'uri'}
          xml.identifier wrapper_object.identifier_handle, {type: 'handle'}

          if wrapper_object.start_time || wrapper_object.end_time
            xml.coverage do
              xml.temporal do
                if wrapper_object.start_time
                  start_datetime = DateTime.parse(wrapper_object.start_time.to_s).strftime("%FT%T%:z")
                  xml.date start_datetime, type: 'dateFrom', dateFormat: 'W3CDTF'
                end
                if wrapper_object.end_time
                  end_datetime = DateTime.parse(wrapper_object.end_time.to_s).strftime("%FT%T%:z")
                  xml.date end_datetime, type: 'dateTo', dateFormat: 'W3CDTF'
                end
              end
            end
          end

          wrapper_object.locations.each do |points|
            xml.coverage do
              points.each do |point|
                xml.spatial "#{point[:long]},#{point[:lat]}", {type: 'gmlKmlPolyCoords', 'xml:lang' => wrapper_object.language}
              end
            end
          end

          wrapper_object.grant_numbers.each do |grant_number|
            xml.relatedObject do
              xml.key grant_number
              xml.relation type: 'isOutputOf'
            end
          end

          wrapper_object.contributors.each do |contributor|
            xml.relatedObject do
              xml.key contributor
              xml.relation type: 'isOutputOf'
            end
          end

          xml.relatedObject do
            xml.key wrapper_object.created_by
            xml.relation type: 'hasCollector' do
              xml.description 'Creator'
            end
          end

          xml.relatedObject do
            xml.key wrapper_object.managed_by
            xml.relation type: 'isManagedBy'
          end

          wrapper_object.primary_contacts.each do |contact|
            xml.relatedObject do
              xml.key contact
              xml.relation type: 'hasAssociationWith' do
                xml.description 'Primary Contact'
              end
            end
          end

          wrapper_object.related_websites.each do |related_website|
            xml.relatedInfo type: 'website' do
              xml.identifier related_website[:url], type: 'uri'
              xml.title related_website[:title]
            end
          end

          wrapper_object.notes.each do |note|
            xml.relatedInfo do
              xml.notes note
            end
          end

        end
      end
    end
  end



end
