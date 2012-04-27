require 'builder'

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
                        'xsi:schemaLocation' => 'http://ands.org.au/standards/rif-cs/registryObjects http://services.ands.org.au/documentation/rifcs/1.3/schema/registryObjects.xsd') do
      xml.registryObject group: wrapper_object.group do
        xml.key wrapper_object.key
        xml.originatingSource wrapper_object.originating_source
        xml.collection type: wrapper_object.collection_type do
          xml.name type: 'primary' do
            xml.namePart wrapper_object.name
          end
          xml.location do
            xml.electronic type: 'url' do
              xml.value wrapper_object.electronic_location
            end
          end
          wrapper_object.local_subjects.each do |subject|
            xml.subject subject, {'type' => 'local', 'xml:lang' => 'en'}
          end
          wrapper_object.for_codes.each do |for_code|
            xml.subject for_code, type: 'anzsrc-for'
          end
          unless wrapper_object.description.blank?
            xml.description wrapper_object.description, type: 'brief'
          end
          wrapper_object.access_rights.each do |right|
            xml.description right, type: 'rights'
          end
          if wrapper_object.start_time || wrapper_object.end_time
            xml.coverage do
              xml.temporal do
                if wrapper_object.start_time
                  xml.date wrapper_object.start_time.strftime('%Y-%m-%d'), type: 'dateFrom', date_format: 'WCCDTF'
                end
                if wrapper_object.end_time
                  xml.date wrapper_object.end_time.strftime('%Y-%m-%d'), type: 'dateTo', date_format: 'WCCDTF'
                end
              end
            end
          end
        end
      end
    end
  end

end