class FacilitiesController < ApplicationController

  set_tab :home

  def index
    set_tab :facilitise, :contentnavigation
    @facilities = Facility.all
  end

  def show
    set_tab :facilitise, :contentnavigation
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

end
