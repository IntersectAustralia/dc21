class ColumnMapping < ActiveRecord::Base

  validates_presence_of :code
  validates_presence_of :name
  validates_uniqueness_of :code

  before_validation :code_lowercase

  default_scope :order => 'name ASC'

  def self.code_to_name_map
    Hash[*all.collect { |cm| [cm.code, cm.name] }.flatten]
  end

  def self.map_names_to_codes(names)
    codes = []
    names.each do |name|
      mappings = ColumnMapping.find_all_by_name(name)
      if mappings.empty?
        codes << name
      else
        mappings.each { |mapping| codes << mapping.code }
      end
    end
    codes
  end

  def code_lowercase
    self.code = self.code.to_s.downcase
  end

end
