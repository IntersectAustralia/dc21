class ExperimentsController < ApplicationController

  SAVE_MESSAGE = 'The experiment was saved successfully.'
  load_and_authorize_resource :facility
  load_and_authorize_resource :through => :facility

  expose(:for_codes) { ForCodesLookup.get_instance.top_level_codes }
  expose(:access_rights) { AccessRightsLookup.new.access_rights }

  def show
  end

  def new
  end

  def edit
  end

  def create
    @experiment.set_for_codes(params[:for_codes])
    if @experiment.save
      redirect_to facility_experiment_path(@facility, @experiment), notice: SAVE_MESSAGE
    else
      render action: "new"
    end
  end

  def update
    success = false
    Experiment.transaction do
      @experiment.set_for_codes(params[:for_codes])
      success = @experiment.update_attributes(params[:experiment])
      raise ActiveRecord::Rollback unless success #tell AR to rollback the transaction but not pass on the error
    end

    if success
      redirect_to facility_experiment_path(@facility, @experiment), notice: SAVE_MESSAGE
    else
      render action: "edit"
    end
  end

end
