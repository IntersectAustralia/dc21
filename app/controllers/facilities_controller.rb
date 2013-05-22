class FacilitiesController < ApplicationController

  load_and_authorize_resource

  set_tab :home
  set_tab :facilities, :contentnavigation
  layout 'data_files'

  def index
  end

  def show
  end

  def new
    @facility = Facility.new
  end

  def create
    primary_contact = params[:primary_contact_select]
    params[:facility][:primary_contact] = User.find(primary_contact)

    if @facility.update_attributes(params[:facility])
      redirect_to @facility, :notice => "Facility successfully added."
    else
      render 'new'
    end
  end

  def edit
    @facility = Facility.find(params[:id])
  end

  def update
    primary_contact = params[:primary_contact_select]
    params[:facility][:primary_contact] = User.find(primary_contact)

    if @facility.update_attributes(params[:facility])
      redirect_to @facility, :notice => "Facility successfully updated."
    else
      render 'edit'
    end
  end

end
