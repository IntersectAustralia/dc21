class ExperimentsController < ApplicationController
  SAVE_MESSAGE = 'The experiment was saved successfully.'
  load_and_authorize_resource :facility
  load_and_authorize_resource :through => :facility

  expose(:access_rights) { AccessRightsLookup.new.access_rights }

  set_tab :home
  set_tab :facilities, :contentnavigation
  layout 'data_files'

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @experiment.save
      redirect_to facility_experiment_path(@facility, @experiment), notice: SAVE_MESSAGE
    else
      @experiment.filter_errors
      render action: "new"
    end
  end

  def update
    success = false
    Experiment.transaction do
      success = @experiment.update_attributes(params[:experiment])
      raise ActiveRecord::Rollback unless success #tell AR to rollback the transaction but not pass on the error
    end

    if success
      redirect_to facility_experiment_path(@facility, @experiment), notice: SAVE_MESSAGE
    else
      @experiment.filter_errors
      render action: "edit"
    end
  end

end
