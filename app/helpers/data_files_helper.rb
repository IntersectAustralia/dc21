module DataFilesHelper

  def grouped_experiments_for_select
    facilities = Facility.order(:name).all
    other = Facility.find_by_name('Other')
    if other
      facilities.delete(other)
      facilities << other
    end

    facilities
  end
end
