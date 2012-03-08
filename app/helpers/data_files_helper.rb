module DataFilesHelper

  def grouped_experiments_for_select(data_file)
    if data_file.facility
      [data_file.facility]
    else
      facilities = Facility.order(:name).all
      other = Facility.new(:name => "Other")
      other_experiment = other.experiments.build(:name => "Other")
      other_experiment.id = -1
      facilities << other

      facilities
    end
  end
end
