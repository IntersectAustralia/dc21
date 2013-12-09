class ColumnMapping < ActiveRecord::Base

  validates_presence_of :code
  validates_presence_of :name
  validates_uniqueness_of :code, :case_sensitive => false
  validates_length_of :code, :maximum => 255

  default_scope :order => 'name ASC'

  def self.code_to_name_map
    Hash[*all.collect { |cm| [cm.code, cm.name] }.flatten]
  end

  # Returns an array of arrays for displaying the column name search checkboxes
  # The elements of the outer array are a 2-element array containing the mapped name,
  # followed by an array of the raw codes that are mapped to that name
  # e.g. [["Temperature", ["temp", "ptemp"]], ["Humidity", "humi", "humidi", "humidity"]]
  def self.mapped_column_names_for_search
    mapped_codes = pluck(:code)

    unmapped_columns = ColumnDetail.unscoped.pluck(:name).uniq
    unmapped_columns.delete_if { |name| mapped_codes.include?(name) }

    grouped = order(:code).group_by(&:name)
    mapped = grouped.collect { |name, mappings| [name, mappings.collect(&:code)] }
    mapped << ["Unmapped", unmapped_columns.sort] unless unmapped_columns.empty?
    mapped
  end

  def check_code_exists?(mappings)
    mappings.each do |existing_map|
      if self.code.to_s.downcase == existing_map.code.to_s.downcase && existing_map.code!="" && self!=existing_map
        return true
      end
    end
    return false
  end

end
