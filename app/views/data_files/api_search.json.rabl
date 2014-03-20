object @data_files
attributes :filename, :created_at, :file_size, :created_by_id, :file_processing_status, :experiment_id
node(:id) { |data_file| data_file.external_id }
node(:file_id) { |data_file| data_file.id }


attributes :facility_id, :format, :path, :updated_at, :start_time, :end_time, :interval, :file_processing_description, :published, :published_date, :published_by_id, :url,  :if => lambda {|x| x.is_authorised_for_access_by?(current_user)}