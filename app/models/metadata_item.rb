class MetadataItem < ActiveRecord::Base

  belongs_to :data_file

  validates_presence_of :data_file_id
  validates_presence_of :key
  validates_presence_of :value

  scope :for_key_with_value_in, lambda {|k, values_array| where{(key.eq k) & (value.in values_array)}}

end
