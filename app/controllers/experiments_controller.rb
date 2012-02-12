class ExperimentsController < ApplicationController

  SAVE_MESSAGE = 'The experiment was saved successfully.'
  load_and_authorize_resource

  def index
    @experiments = @experiments.order(:name)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @experiment.save
      redirect_to @experiment, notice: SAVE_MESSAGE
    else
      render action: "new"
    end
  end

  def update
    if @experiment.update_attributes(params[:experiment])
      redirect_to @experiment, notice: SAVE_MESSAGE
    else
      render action: "edit"
    end
  end

  def destroy
    @experiment.destroy
    redirect_to experiments_url
  end
end
