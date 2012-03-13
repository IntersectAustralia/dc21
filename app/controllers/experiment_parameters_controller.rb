class ExperimentParametersController < ApplicationController

  load_and_authorize_resource :facility
  load_and_authorize_resource :experiment, :through => :facility
  load_and_authorize_resource :through => :experiment

  expose(:parameter_categories) { ParameterCategory.by_name }
  expose(:parameter_modifications) { ParameterModification.by_name }

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

  ## DELETE /experiment_parameters/1
  ## DELETE /experiment_parameters/1.json
  #def destroy
  #  @experiment_parameter = ExperimentParameter.find(params[:id])
  #  @experiment_parameter.destroy
  #
  #  respond_to do |format|
  #    format.html { redirect_to experiment_parameters_url }
  #    format.json { head :ok }
  #  end
  #end
end
