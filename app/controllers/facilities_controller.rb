class FacilitiesController < ApplicationController

  set_tab :home
  set_tab :facilities, :contentnavigation

  def index
    @facilities = Facility.all
  end

  def show
    @facility = Facility.find(params[:id])
  end

  def new
    @facility = Facility.new
  end

  def create
    @facility = Facility.new(params[:facility])
    if @facility.save
      redirect_to @facility
      flash[:success] = "Facility successfully added"
    else 
      render 'new'
    end
  end

  def edit
    @facility = Facility.find(params[:id])
  end

  def update
    @facility = Facility.find(params[:id])
    if @facility.update_attributes(params[:facility])
      redirect_to @facility
      flash[:success] = "Facility successfully updated."
    else
      render 'edit'
    end
  end

  private
  def default_layout
    "main"
  end
end
