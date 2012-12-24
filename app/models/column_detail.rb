class ColumnDetail < ActiveRecord::Base
  belongs_to :data_file

  validates_presence_of :data_file_id
  validates_presence_of :name

  default_scope order(:position)

  def get_mapped_name
    ColumnMapping.all.each do |map|
      if map.code.downcase == self.name.downcase
        return map.name
      end
    end
    nil
  end

end
