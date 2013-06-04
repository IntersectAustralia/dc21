class ExperimentParametersController < ApplicationController
  load_and_authorize_resource :facility
  load_and_authorize_resource :experiment, :through => :facility
  load_and_authorize_resource :through => :experiment

  expose(:parameter_categories) { ParameterCategory.by_name }
  expose(:parameter_modifications) { ParameterModification.by_name }
  expose(:parameter_units) { ParameterUnit.by_name }

  set_tab :home
  set_tab :facilities, :contentnavigation
  layout 'data_files'

  def new
  end

  def create
    if @experiment_parameter.save
      redirect_to facility_experiment_url(@facility, @experiment), notice: 'The experiment parameter was successfully created.'
    else
      render action: "new"
    end
  end

  def edit
  end

  def update
    if @experiment_parameter.update_attributes(params[:experiment_parameter])
      redirect_to facility_experiment_url(@facility, @experiment), notice: 'The experiment parameter was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @experiment_parameter.destroy
    redirect_to facility_experiment_url(@facility, @experiment), notice: 'The experiment parameter has been deleted.'
  end
end
