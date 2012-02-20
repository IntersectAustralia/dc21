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
    contacts = params.delete(:contact_ids)
    primary = params.delete(:contact_primary)
    contacts.delete(primary) unless contacts.blank?

    params[:facility][:contact_ids] = contacts
    if primary.present?
      u = User.find(primary)
      params[:facility][:primary_contact] = u
    end

    @facility = Facility.new(params[:facility])

    if @facility.save
      redirect_to @facility, :notice => "Facility successfully added"
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    contacts = params.delete(:contact_ids)
    primary = params.delete(:contact_primary)
    contacts.delete(primary) unless contacts.blank?

    params[:facility][:contact_ids] = contacts
    params[:facility][:primary_contact] = (primary.present? ? User.find(primary) : nil)


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
