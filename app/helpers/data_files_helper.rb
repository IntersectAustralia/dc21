module DataFilesHelper

  def grouped_experiments_for_select
    facilities = Facility.order(:name).all
    other = Facility.new(:name => "Other")
    other_experiment = other.experiments.build(:name => "Other")
    other_experiment.id = -1
    facilities << other

    facilities
  end
end
