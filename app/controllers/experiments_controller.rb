class ExperimentsController < ApplicationController
  SAVE_MESSAGE = 'The experiment was saved successfully.'
  load_and_authorize_resource :facility
  load_and_authorize_resource :through => :facility

  expose(:access_rights) { AccessRightsLookup.new.access_rights }
  expose(:for_codes) { ForCodesLookup.get_instance.top_level_codes }

  set_tab :home
  set_tab :facilities, :contentnavigation
  layout 'data_files'

  def show
  end

  def new
    @experiment = Experiment.new
    @facility = Facility.find(params[:facility_id])
  end

  def edit
    @experiment = Experiment.find(params[:id])
    @facility = Facility.find(params[:facility_id])
  end

  def create
    success = false
    Experiment.transaction do
      @experiment.set_for_codes(params[:for_codes])
      success = @experiment.update_attributes(params[:experiment])
      raise ActiveRecord::Rollback unless success
    end

    if success
      redirect_to facility_experiment_path(@facility, @experiment), notice: SAVE_MESSAGE
    else
      @experiment.filter_errors
      render action: "new"
    end
  end

  def update
    success = false
    Experiment.transaction do
      @experiment.set_for_codes(params[:for_codes])
      success = @experiment.update_attributes(params[:experiment])
      raise ActiveRecord::Rollback unless success
    end

    if success
      redirect_to facility_experiment_path(@facility, @experiment), notice: SAVE_MESSAGE
    else
      @experiment.filter_errors
      render 'edit'
    end
  end

end
