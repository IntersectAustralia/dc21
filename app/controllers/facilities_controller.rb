class FacilitiesController < ApplicationController

  load_and_authorize_resource

  set_tab :home
  set_tab :facilities, :contentnavigation

  def index
  end

  def show
  end

  def new
  end

  def create
    if @facility.save
      redirect_to @facility, :notice => "Facility successfully added"
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @facility.update_attributes(params[:facility])
      redirect_to @facility, :notice => "Facility successfully updated."
    else
      render 'edit'
    end
  end

  private
  def default_layout
    "main"
  end
end
