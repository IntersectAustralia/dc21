object @data_files
attributes :filename, :format, :path, :created_at, :updated_at, :created_by_id, :start_time, :end_time, :interval, :file_processing_status, :file_processing_description, :experiment_id, :file_size, :published, :published_date, :published_by_id, :url

node(:id) { |data_file| data_file.external_id }
node(:file_id) { |data_file| data_file.id }