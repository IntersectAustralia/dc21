class UpdateDataFileFormats < ActiveRecord::Migration
  def change
    DataFile.find_each do |df|
      if File.exists?(df.path)
        df.format = FileTypeDeterminer.new.identify_file(df)
        df.save
      end
    end
  end
end
