class DataFileRelationship < ActiveRecord::Base
  belongs_to :parent, :class_name => "DataFile"
  belongs_to :child, :class_name => "DataFile"
end
