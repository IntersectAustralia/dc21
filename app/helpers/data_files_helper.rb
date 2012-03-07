module DataFilesHelper

  def grouped_experiments_for_select(data_file)
    facilities = Facility.order(:name).all

    # if data_file belongs to a facility, put that at the top of the dropdown, and sort the others by name
    if data_file.facility
      facilities.sort_by! { |f| [(f.id == data_file.facility.id ? 0 : 1), f.name] }
    end

    other = Facility.new(:name => "Other")
    other_experiment = other.experiments.build(:name => "Other")
    other_experiment.id = -1
    facilities << other

    facilities
  end
end
