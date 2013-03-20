module DataFilesHelper

  def grouped_experiments_for_select
    Facility.order(:name).all
  end
end
