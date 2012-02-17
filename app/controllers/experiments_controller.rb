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
    @experiment.set_for_codes(params[:for_codes])
    if @experiment.update_attributes(params[:experiment])
      redirect_to facility_experiment_path(@facility, @experiment), notice: SAVE_MESSAGE
    else
      render action: "edit"
    end
  end

end
