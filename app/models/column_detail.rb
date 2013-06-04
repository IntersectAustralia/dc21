class ColumnDetail < ActiveRecord::Base
  belongs_to :data_file

  validates_presence_of :data_file_id
  validates_presence_of :name

  default_scope order(:position)

  def get_mapped_name
    ColumnMapping.where("code ilike '#{self.name}'").select('name').first.try(:name)
  end

end
