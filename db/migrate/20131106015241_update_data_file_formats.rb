class UpdateDataFileFormats < ActiveRecord::Migration
  def change
    DataFile.find_each do |df|
      df.format = FileTypeDeterminer.new.identify_file(df)
      df.save
    end
  end
end
