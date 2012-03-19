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
    @facility = Facility.find(params[:id])

    result = false
    ActiveRecord::Base.transaction do
      #Nested associations are misbehaving, so manually replace the contacts on update
      @facility.aggregated_contactables.each do |ag_cont|
        ag_cont.delete
      end
      @facility.assign_attributes(params[:facility])

      unless primary.blank?
        @facility.primary_contactable = FacilityContact.new({:facility_id => @facility.id, :user_id => primary, :primary => true})
      end
      result = @facility.save
    end

    if result
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
