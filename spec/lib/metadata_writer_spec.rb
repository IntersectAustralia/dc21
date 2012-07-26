require 'spec_helper'

describe MetadataWriter do
  describe "Write metadata to file" do
    it "should produce a file with details written one per line" do
      primary_contact = Factory(:user,
                                first_name: 'Prim',
                                last_name: 'Contact',
                                email: 'prim@intersect.org.au')

      facility = Factory(:facility, 
                         name: 'Whole Tree Chambers',
                         id: 1,
                         code: 'WTC',
                         description: 'The Whole Tree Chambers (WTC) facility was installed',
                         a_lat: 20, a_long: 30,
                         primary_contact: primary_contact)

      directory = Dir.mktmpdir
      file_path = subject.write_facility_metadata(facility, directory)
      file_path.should =~ /whole-tree-chambers.txt/
      file_path.should be_same_file_as(Rails.root.join('samples/metadata/facility.txt'))
    end
  end
end
