require 'builder'

# This class builds the RIF-CS for a collection, delegating to a wrapper object to find the necessary values.
# The idea is that this can be reused across projects, and that the project-specific details of what goes into
# the rifcs are encoded in the wrapper class. Create your own wrapper by subclassing RifCsWrapper.

class RifCsGenerator

  attr_accessor :wrapper_object, :xml

  def initialize(wrapper_object, target)
    self.wrapper_object = wrapper_object
    self.xml = Builder::XmlMarkup.new :target => target
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
        end
      end
    end
  end

end